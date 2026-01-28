document.addEventListener('DOMContentLoaded', function() {
  document.querySelectorAll('.sidebar-toggle').forEach(function(btn) {
    btn.addEventListener('click', function(e) {
      // Don't prevent default if clicking on an actual link inside
      if (e.target.tagName === 'A') {
        return;
      }
      e.preventDefault();
      var targetId = this.getAttribute('data-target');
      var target = document.getElementById(targetId);
      var icon = this.querySelector('.toggle-icon');

      if (target && target.classList.contains('collapsed')) {
        target.classList.remove('collapsed');
        if (icon) icon.innerHTML = '&#9660;';
      } else if (target) {
        target.classList.add('collapsed');
        if (icon) icon.innerHTML = '&#9654;';
      }
    });
  });
});
