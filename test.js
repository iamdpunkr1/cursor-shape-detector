const { getCursorShape, cleanup } = require("./index");

let interval =  setInterval(()=>{
    console.log("Cursor Shape: ", getCursorShape());
},100);


setTimeout(()=>{
    clearInterval(interval)
},3000);