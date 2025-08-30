// Tab functionality
function initializeTabs() {
  const tabs = document.querySelectorAll('.tab');
  const contents = document.querySelectorAll('.tab-content');
  
  tabs.forEach(tab => {
    tab.addEventListener('click', () => {
      // Remove active class from all tabs and contents
      tabs.forEach(t => t.classList.remove('active'));
      contents.forEach(c => c.classList.add('hidden'));
      
      // Add active class to clicked tab and corresponding content
      tab.classList.add('active');
      const targetId = tab.getAttribute('data-target');
      document.getElementById(targetId).classList.remove('hidden');
    });
  });
}

// Toggle functionality
function initializeToggles() {
  const toggles = document.querySelectorAll('.view-toggle');
  
  toggles.forEach(toggle => {
    toggle.addEventListener('change', (e) => {
      const panel = e.target.closest('.panel');
      const diagramContainers = panel.querySelectorAll('.diagram-container');
      const codeContainers = panel.querySelectorAll('.code-container');
      
      if (e.target.checked) {
        // Show code
        diagramContainers.forEach(d => d.classList.add('hidden'));
        codeContainers.forEach(c => c.classList.remove('hidden'));
      } else {
        // Show diagram
        diagramContainers.forEach(d => d.classList.remove('hidden'));
        codeContainers.forEach(c => c.classList.add('hidden'));
      }
    });
  });
}

// Copy button functionality
function initializeCopyButtons() {
  const copyButtons = document.querySelectorAll('.copy-button');
  
  copyButtons.forEach(button => {
    button.addEventListener('click', async () => {
      const codeBlock = button.closest('.code-container').querySelector('code');
      const text = codeBlock.textContent;
      
      try {
        await navigator.clipboard.writeText(text);
        button.textContent = 'Copied!';
        button.classList.add('copied');
        
        setTimeout(() => {
          button.textContent = 'Copy';
          button.classList.remove('copied');
        }, 2000);
      } catch (err) {
        console.error('Failed to copy:', err);
      }
    });
  });
}

// Modal/Lightbox functionality
let modal, modalImg, modalCaption;

function createModal() {
  // Create modal structure
  modal = document.createElement('div');
  modal.className = 'modal';
  modal.innerHTML = `
    <span class="modal-close">&times;</span>
    <div class="modal-content">
      <img src="" alt="Enlarged diagram">
    </div>
    <div class="modal-caption"></div>
  `;
  document.body.appendChild(modal);
  
  modalImg = modal.querySelector('img');
  modalCaption = modal.querySelector('.modal-caption');
  const modalClose = modal.querySelector('.modal-close');
  
  // Close modal function
  const closeModal = () => {
    modal.style.display = 'none';
    document.body.style.overflow = '';
  };
  
  // Close on X button click
  modalClose.addEventListener('click', closeModal);
  
  // Close on ESC key
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && modal.style.display === 'block') {
      closeModal();
    }
  });
  
  // Close on click outside the image
  modal.addEventListener('click', (e) => {
    if (e.target === modal || e.target === modal.querySelector('.modal-content')) {
      closeModal();
    }
  });
}

function attachImageClickHandlers() {
  // Add click handlers to all currently visible diagram images
  const diagramImages = document.querySelectorAll('.diagram-container:not(.hidden) img');
  diagramImages.forEach(img => {
    // Remove any existing handler to avoid duplicates
    img.removeEventListener('click', handleImageClick);
    img.addEventListener('click', handleImageClick);
  });
}

function handleImageClick(e) {
  const img = e.target;
  modal.style.display = 'block';
  modalImg.style.display = 'none'; // Hide until loaded
  modalCaption.textContent = 'Loading...';
  
  // Create new image to preload
  const tempImg = new Image();
  tempImg.onload = () => {
    modalImg.src = img.src;
    modalImg.style.display = 'block';
    modalCaption.textContent = img.alt || 'Diagram';
  };
  tempImg.src = img.src;
  
  // Prevent body scroll when modal is open
  document.body.style.overflow = 'hidden';
}

function initializeModal() {
  createModal();
  attachImageClickHandlers();
  
  // Re-attach handlers when tabs change or toggles are used
  const observer = new MutationObserver(() => {
    attachImageClickHandlers();
  });
  
  // Observe changes to hidden class on diagram containers
  document.querySelectorAll('.tab-content, .diagram-container').forEach(el => {
    observer.observe(el, { attributes: true, attributeFilter: ['class'] });
  });
}

// Initialize everything when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  initializeTabs();
  initializeToggles();
  initializeCopyButtons();
  initializeModal();
  
  // Set first tab as active by default
  const firstTab = document.querySelector('.tab');
  if (firstTab) {
    firstTab.click();
  }
});
