const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const cors = require('cors');
const bodyParser = require('body-parser');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 5000;


// Enable CORS
app.use(cors());


// Set up SQLite database
const db = new sqlite3.Database(path.resolve(__dirname, 'FisheriesData.db'), (err) => {
  if (err) {
    console.error('Error opening database', err.message);
  } else {
    console.log('Connected to the SQLite database.');
    db.run(`CREATE TABLE IF NOT EXISTS single_player_data (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT,
      objective TEXT,
      total_capture REAL,
      total_profit REAL,
      capture TEXT,
      profit TEXT,
      fish_population TEXT,
      ships TEXT,
      timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    )`);
  }
});


// Middleware
app.use(bodyParser.json());


// API endpoint to receive data
app.post('/submit-data', (req, res) => {
  const { capture, fish_population, objective, profit, ships, total_capture, total_profit, username } = req.body;
  db.run(`INSERT INTO single_player_data(username, objective, total_capture, total_profit, capture, profit, fish_population, ships) VALUES(?, ?, ?, ?, ?, ?, ?, ?)`, [username, objective, total_capture, total_profit, capture, profit, fish_population, ships], function (err) {
    if (err) {
      console.log(err)
      res.status(500).send('Error saving data');
    } else {
      console.log('Data saved')
      res.status(200).json({ id: this.lastID });
    }
  });
});


// API endpoint to retrieve leaderboard based on objective
app.get('/leaderboard', (req, res) => {
  const objective = req.query.objective;
  const score_column = (objective === 'Capture') ? 'total_capture' : 'total_profit';
  
  db.all(`SELECT username, ${score_column} as score FROM single_player_data WHERE objective = ? ORDER BY ${score_column} DESC LIMIT 5`, 
    [objective], (err, rows) => {
    if (err) {
      console.error('Error retrieving leaderboard:', err.message);
      res.status(500).send('Error retrieving leaderboard');
    } else {
      res.status(200).json(rows);
    }
  });
});


// Serve the statistics page
app.get('/statistics', (req, res) => {
  res.sendFile(path.join(__dirname, '..', 'public', 'statistics.html'));
});


// API endpoint to get all players
app.get('/api/players', (req, res) => {
  db.all('SELECT * FROM single_player_data ORDER BY timestamp ASC', (err, rows) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.status(200).json({ players: rows });
  });
});


// API endpoint to get player by ID
app.get('/api/players/:id', (req, res) => {
  const id = req.params.id;
  db.get('SELECT * FROM single_player_data WHERE id = ?', [id], (err, row) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.status(200).json({ player: row });
  });
});


app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
