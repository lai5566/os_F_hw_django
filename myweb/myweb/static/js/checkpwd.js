function isValidPassword(password) {

    if (password.length < 8) {
        return false;
    }
    const lowercaseRegex = /[a-z]/;
    const uppercaseRegex = /[A-Z]/;
    const digitRegex = /[0-9]/;  
    if (!lowercaseRegex.test(password) || !uppercaseRegex.test(password) || !digitRegex.test(password)) {
        return false;
    }      
    return true;
}

const passwordInput = document.getElementById("password");
const confirmPasswordInput = document.getElementById("confirmpassword");
const passwordMismatchMessage = document.getElementById("passwordMismatch");
const passwordValidationResult = document.getElementById("passwordValidationResult");
const submitButton = document.getElementById("submitButton");
var isUserIDverified=false;
passwordInput.addEventListener("input", checkPasswordMatch);
confirmPasswordInput.addEventListener("input", checkPasswordMatch);
passwordInput.addEventListener("input", checkPasswordValidity);

function checkPasswordMatch() {
    const password = passwordInput.value;
    const confirmPassword = confirmPasswordInput.value;

    if (password === confirmPassword) {
        passwordMismatchMessage.textContent = "";
    } else {
        passwordMismatchMessage.textContent = "請確認輸入的密碼是否相同";
    }
}

function checkPasswordValidity() {
    const password = passwordInput.value;
    if (isValidPassword(password) && isUserIDverified) { 
        enableSubmitButton();
    }else if (isValidPassword(password)){
        passwordValidationResult.textContent = "";
    } else {
        passwordValidationResult.textContent = "密碼需要包含大小寫英文及數字，長度需大於8碼";
        disableSubmitButton();
    }
}
function enableSubmitButton() {
  submitButton.removeAttribute("disabled");
}

function disableSubmitButton() {
  submitButton.setAttribute("disabled", "true");
}

// Get the button, input, and error message elements
var checkButton = document.getElementById("checkUserID");
var userInput = document.getElementById("userIDInput");
var errorMessage = document.getElementById("errorMessage");

// Execute an AJAX request when the button is clicked
checkButton.addEventListener("click", function() {
  // Get the user-entered employee ID
  var userID = userInput.value;

  // Check if userID is empty
  if (userID.trim() === "") {
    // Display an error message and return
    errorMessage.textContent = "使用者編號不得為空值";
    return;
  } else {
    // Clear the error message if userID is not empty
    errorMessage.textContent = "";
  }

  // Create a new XMLHttpRequest object
  var xhr = new XMLHttpRequest();

  // Configure the request
  xhr.open("POST", "/check_user_existence/", true); // Replace with your view URL
  xhr.setRequestHeader("Content-Type", "application/json; charset=utf-8");

  // Set up the response handling function
  xhr.onreadystatechange = function() {
    if (xhr.readyState === 4) {
      if (xhr.status === 200) {
        // Handle the response data
        var response = JSON.parse(xhr.responseText);
        if (response.Code === "A02") {
          // If the user exists, set the button text to "Not Available" and style it in red
          checkButton.textContent = "X";
          checkButton.style.backgroundColor = "#c05c5c";
          errorMessage.textContent = "使用者編號已有人使用";
        } else if (response.Code === "A01") {
          // If the user doesn't exist, set the button text to "Available" and style it in green
          checkButton.textContent = "V";
          checkButton.style.backgroundColor = "#3f9870";
          errorMessage.textContent = "";
          const password = passwordInput.value;
          if (isValidPassword(password) && isUserIDverified) { 
              enableSubmitButton();
          }
          isUserIDverified=true;
        } else {
          // Handle other error cases
          console.log('E99');
        }
      } else {
        console.log("Request failed");
      }
    }
  };

  // Send the request and send data as a JSON string
  var data = JSON.stringify({ "userID": userID });
  xhr.send(data);
});