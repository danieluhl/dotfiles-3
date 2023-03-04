// check last login date
const loginData = require("./login.json");
const fs = require("fs");
const path = require("path");
const { exec } = require("node:child_process");
const os = require("os");
const userHomeDir = os.homedir();

// git pull latest dotfiles
const lastLogin = new Date(loginData.lastLoginTimestamp);
const today = new Date();
console.log(today.getDay());
console.log(lastLogin.getDay());
if (today.getDay() !== lastLogin.getDay()) {
  console.log("********************");
  console.log("UPDATING dotfiles and warp bg");
  // update background picture
  // exec("npx get-warp-bg");
  // const loginShellPath = path.join(process.cwd(), "login.sh");
  exec(
    path.join(userHomeDir, "git/dotfiles/public/login.sh"),
    (error, stdout, stderr) => {
      if (error) {
        console.error(`error running login.js: ${error}`);
        return;
      } else {
        console.log(`stdout: ${stdout}`);
        console.error(`stderr: ${stderr}`);
        console.log("bg updated! RELOAD to see the greatness!");
        console.log("********************");
      }
    }
  );
  // log updated and say to restart browser, otherwise, clear the terminal
  loginData.lastLoginTimestamp = today.getTime();
  fs.writeFile(
    path.join(userHomeDir, "git/dotfiles/public/login.json"),
    JSON.stringify(loginData),
    (err) => {
      console.log(`new data: ${JSON.stringify(loginData)}`);
      if (err) {
        console.log(err);
      } else {
        console.log("login data successfully updated");
      }
    }
  );
} else {
  console.clear();
}
