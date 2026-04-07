// 页面交互原型 - 仅用于静态演示

document.addEventListener('DOMContentLoaded', () => {
  // 助手列表切换
  document.querySelectorAll('.assistant-item').forEach(item => {
    item.addEventListener('click', () => {
      document.querySelector('.assistant-item.active')?.classList.remove('active');
      item.classList.add('active');
    });
  });

  // 详情面板开关
  const panel = document.getElementById('detailPanel');
  document.getElementById('detailToggleBtn')?.addEventListener('click', () => panel.classList.toggle('open'));
  document.getElementById('detailCloseBtn')?.addEventListener('click', () => panel.classList.remove('open'));

  // 电话模式切换
  const callBtn = document.getElementById('callBtn');
  callBtn?.addEventListener('click', () => {
    callBtn.classList.toggle('active');
    callBtn.title = callBtn.classList.contains('active') ? '挂断语音通话' : '语音通话模式';
  });

  // 弹窗通用开关
  function toggleModal(id, show) {
    document.getElementById(id)?.classList.toggle('show', show);
  }

  document.getElementById('addAssistantBtn')?.addEventListener('click', () => toggleModal('editModal', true));
  document.getElementById('settingsBtn')?.addEventListener('click', () => toggleModal('settingsModal', true));

  document.querySelectorAll('.modal-close-btn, .modal-footer .btn-ghost').forEach(btn => {
    btn.addEventListener('click', () => {
      btn.closest('.modal-overlay')?.classList.remove('show');
    });
  });

  // 点击遮罩关闭
  document.querySelectorAll('.modal-overlay').forEach(overlay => {
    overlay.addEventListener('click', e => {
      if (e.target === overlay) overlay.classList.remove('show');
    });
  });
});
