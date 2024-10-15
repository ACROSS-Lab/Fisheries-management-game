document.addEventListener('DOMContentLoaded', (event) => {
    fetch('/api/players')
      .then(response => response.json())
      .then(data => {
        const select = document.getElementById('playerSelect');
        data.players.forEach(player => {
          const option = document.createElement('option');
          option.value = player.id;
          option.textContent = `${player.username} - ${player.timestamp}`;
          select.appendChild(option);
        });

        const urlParams = new URLSearchParams(window.location.search);
        const autoSelectId = urlParams.get('autoSelectId');
        if (autoSelectId) {
          select.value = autoSelectId;
          fetchPlayerData();
        }
      });
  });

  function fetchPlayerData() {
    const select = document.getElementById('playerSelect');
    const playerId = select.value;
    if (playerId) {
      fetch(`/api/players/${playerId}`)
        .then(response => response.json())
        .then(data => {
          const playerData = document.getElementById('playerData');
          playerData.textContent = JSON.stringify(data.player);
        });
    } else {
      document.getElementById('playerData').textContent = '';
    }
  }