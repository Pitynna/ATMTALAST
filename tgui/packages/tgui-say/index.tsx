import { createRoot } from 'react-dom/client';

import { TguiSay } from './TguiSay';

function mount() {
  const root = document.getElementById('react-root');
  if (root) createRoot(root).render(<TguiSay />);
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', mount, { once: true });
} else {
  mount();
}
