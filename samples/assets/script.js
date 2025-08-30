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

// Toggle functionality - now handles global toggle
function initializeToggles() {
  const globalToggle = document.querySelector('.view-toggle-global');
  
  if (globalToggle) {
    globalToggle.addEventListener('change', (e) => {
      const allDiagramContainers = document.querySelectorAll('.diagram-container');
      const allCodeContainers = document.querySelectorAll('.code-container');
      
      if (e.target.checked) {
        // Show code
        allDiagramContainers.forEach(d => d.classList.add('hidden'));
        allCodeContainers.forEach(c => c.classList.remove('hidden'));
      } else {
        // Show diagram
        allDiagramContainers.forEach(d => d.classList.remove('hidden'));
        allCodeContainers.forEach(c => c.classList.add('hidden'));
      }
      
      // Re-attach image click handlers after toggle
      attachImageClickHandlers();
    });
  }
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

function getOrCreateModal() {
  // Check if modal already exists
  modal = document.getElementById('imageModal');
  if (modal) {
    modalImg = document.getElementById('modalImage');
    modalCaption = document.getElementById('modalCaption');
    return;
  }
  
  // Create modal structure if it doesn't exist
  modal = document.createElement('div');
  modal.id = 'imageModal';
  modal.className = 'modal';
  modal.innerHTML = `
    <span class="modal-close">&times;</span>
    <div class="modal-content">
      <img id="modalImage" src="" alt="Enlarged diagram">
    </div>
    <div id="modalCaption" class="modal-caption"></div>
  `;
  document.body.appendChild(modal);
  
  modalImg = document.getElementById('modalImage');
  modalCaption = document.getElementById('modalCaption');
}

function initializeModal() {
  getOrCreateModal();
  
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
  
  attachImageClickHandlers();
  
  // Re-attach handlers when tabs change
  const observer = new MutationObserver(() => {
    attachImageClickHandlers();
  });
  
  // Observe changes to hidden class on tab contents
  document.querySelectorAll('.tab-content').forEach(el => {
    observer.observe(el, { attributes: true, attributeFilter: ['class'] });
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