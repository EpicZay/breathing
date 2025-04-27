let isVisible = false;
const CIRCLE_CIRCUMFERENCE = 2 * Math.PI * 35; // Based on radius of the circle (35)

window.addEventListener('message', function(event) {
    const data = event.data;
    const container = document.getElementById('breath-container');
    const warningElement = document.getElementById('breath-warning');
    const statusText = document.getElementById('status-text');
    const progressCircle = document.getElementById('progress-circle');
    const breathValue = document.getElementById('breath-value');
    const multiplierElement = document.getElementById('breath-multiplier');
    
    // Set up the circle progress
    progressCircle.style.strokeDasharray = CIRCLE_CIRCUMFERENCE;
    
    if (data.type === "showBreathWarning") {
        container.style.opacity = '1';
        isVisible = true;
        
        // Set initial breath level
        updateProgressCircle(data.breathLevel);
        document.getElementById('breath-level').style.width = data.breathLevel + '%';
        
        // Show breath percentage
        breathValue.textContent = Math.round(data.breathLevel) + '%';
        
        // Display multiplier if applicable
        if (data.multiplier && Math.abs(data.multiplier - 1.0) > 0.01) {
            const multiplierText = data.multiplier > 1 ? 
                `${(data.multiplier).toFixed(1)}x faster` : 
                `${(1/data.multiplier).toFixed(1)}x slower`;
            
            multiplierElement.textContent = `Breathing: ${multiplierText}`;
            multiplierElement.style.display = 'block';
            
            // Set multiplier color
            if (data.multiplier > 1.1) {
                multiplierElement.style.color = '#e74c3c'; // red for faster
            } else if (data.multiplier < 0.9) {
                multiplierElement.style.color = '#2ecc71'; // green for slower
            } else {
                multiplierElement.style.color = '#f39c12'; // yellow for small changes
            }
        } else {
            multiplierElement.style.display = 'none';
        }
        
        // Display seconds remaining in the status text
        updateStatusText(data.secondsLeft, data.isUnderwater, data.hasMask);
        
        // Change UI appearance based on underwater status and mask
        updateEnvironmentClasses(warningElement, data.isUnderwater, data.hasMask);
        
        // Add critical class if breath level is low
        if (data.breathLevel <= 30.0) {
            warningElement.classList.add('critical');
        } else {
            warningElement.classList.remove('critical');
        }
        
        // Add time warning classes
        updateTimeWarningClasses(warningElement, data.secondsLeft);
    }
    
    else if (data.type === "hideBreathWarning") {
        container.style.opacity = '0';
        isVisible = false;
    }
    
    else if (data.type === "updateBreathLevel") {
        // Update breath level display
        updateProgressCircle(data.breathLevel);
        document.getElementById('breath-level').style.width = data.breathLevel + '%';
        breathValue.textContent = Math.round(data.breathLevel) + '%';
        
        // Update multiplier if applicable
        if (data.multiplier && Math.abs(data.multiplier - 1.0) > 0.01) {
            const multiplierText = data.multiplier > 1 ? 
                `${(data.multiplier).toFixed(1)}x faster` : 
                `${(1/data.multiplier).toFixed(1)}x slower`;
            
            multiplierElement.textContent = `Breathing: ${multiplierText}`;
            multiplierElement.style.display = 'block';
            
            // Set multiplier color
            if (data.multiplier > 1.1) {
                multiplierElement.style.color = '#e74c3c'; // red for faster
            } else if (data.multiplier < 0.9) {
                multiplierElement.style.color = '#2ecc71'; // green for slower
            } else {
                multiplierElement.style.color = '#f39c12'; // yellow for small changes
            }
        } else {
            multiplierElement.style.display = 'none';
        }
        
        // Update status text with seconds remaining
        updateStatusText(data.secondsLeft, data.isUnderwater, data.hasMask);
        
        // Update environment classes
        updateEnvironmentClasses(warningElement, data.isUnderwater, data.hasMask);
        
        // Update time warning classes
        updateTimeWarningClasses(warningElement, data.secondsLeft);
        
        // Flash warning when critically low on breath
        if (data.breathLevel <= 30.0) {
            warningElement.classList.add('critical');
            
            if (data.breathLevel <= 15.0) {
                warningElement.classList.remove('warning-flash');
                void warningElement.offsetWidth; // Trigger reflow to restart animation
                warningElement.classList.add('warning-flash');
            }
        } else {
            warningElement.classList.remove('critical');
        }
    }
    
    else if (data.type === "deepBreath") {
        // Visual feedback when taking a breath
        let originalBorderColor = '#27ae60'; // default
        
        if (data.isUnderwater) {
            originalBorderColor = '#e74c3c';
        } else if (data.hasMask) {
            originalBorderColor = '#3498db';
        }
        
        warningElement.classList.add('deep-breath');
        warningElement.style.borderColor = '#2ecc71';
        
        // Show breath taken message and update breath value
        statusText.textContent = "Breath taken! 10s until next breath.";
        breathValue.textContent = "100%";
        
        // Remove warning classes
        warningElement.classList.remove('time-warning', 'time-critical');
        
        setTimeout(() => {
            warningElement.classList.remove('deep-breath');
            warningElement.style.borderColor = originalBorderColor;
            
            // Update status text
            updateStatusText(10, data.isUnderwater, data.hasMask);
        }, 1000);
    }
});

// Function to update the circular progress bar
function updateProgressCircle(percent) {
    const progressCircle = document.getElementById('progress-circle');
    const dashoffset = CIRCLE_CIRCUMFERENCE * (1 - percent / 100);
    progressCircle.style.strokeDashoffset = dashoffset;
}

// Function to update status text based on seconds remaining
function updateStatusText(secondsLeft, isUnderwater, hasMask) {
    const statusText = document.getElementById('status-text');
    
    // Get environment prefix
    let prefix = "";
    if (isUnderwater) {
        prefix = "Underwater - ";
    } else if (hasMask) {
        prefix = "Oxygen Mask - ";
    }
    
    // Get urgency message
    let message = "";
    if (secondsLeft <= 2) {
        message = "BREATHE NOW!";
    } else if (secondsLeft <= 4) {
        message = "Breathe immediately!";
    } else if (secondsLeft <= 6) {
        message = "Need to breathe soon!";
    } else {
        message = "Remember to breathe regularly";
    }
    
    statusText.textContent = prefix + message;
}

// Function to update time warning classes
function updateTimeWarningClasses(element, secondsLeft) {
    if (secondsLeft <= 2) {
        element.classList.add('time-critical');
        element.classList.remove('time-warning');
    } else if (secondsLeft <= 4) {
        element.classList.add('time-warning');
        element.classList.remove('time-critical');
    } else {
        element.classList.remove('time-warning', 'time-critical');
    }
}

// Function to update environment classes
function updateEnvironmentClasses(element, isUnderwater, hasMask) {
    // Remove all environment classes first
    element.classList.remove('underwater', 'above-water', 'oxygen-mask');
    
    // Add appropriate class
    if (isUnderwater) {
        element.classList.add('underwater');
    } else if (hasMask) {
        element.classList.add('oxygen-mask');
    } else {
        element.classList.add('above-water');
    }
} 