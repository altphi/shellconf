OddPageNumbers = app.trustedFunction(function()
{

var dialogTitle = "Question.";
var reply = app.response("What logical page do you wish to begin on?",
			 dialogTitle);

var dialogTitle2 = "Question 2.";
var reply2 = app.response("What new number do you wish to begin with?",
			 dialogTitle2);

var dialogTitle3 =" D       =   decimal numbering \n R or r  = roman numbering, upper or lower case \n  A or a  = alphabetic numbering, upper or lower case";
var reply3 = app.response("What type of numbering do you wish to use?",
			                            dialogTitle);

    var i = reply - 1;
    var newnum = reply2;
    while (i < this.numPages)
    {
      this.setPageLabels(i, [reply3, "", newnum]);
      newnum++;
      newnum++;
      i++;
    };
}
)




// add the menu item
app.addMenuItem({
     cName: "OddPageNumsJS",     // this is the internal name used for this menu item
     cUser: "Odd Page Numbers",       // this is the label that is used to display the menu item
     cParent: "Edit",              // this is the parent menu. The file menu would use "File"
     cExec: "OddPageNumbers()",  // this is the JavaScript code to execute when this menu item is selected
     cEnable: "event.rc = (event.target != null);",       // when should this menu item be active?
     nPos: 0
});
