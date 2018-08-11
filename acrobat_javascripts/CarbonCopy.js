ProcessCarbonCopy = app.trustedFunction(function()
{
var nNumCopies = 1; // make 1 additional copy(es) of each page

var dialogTitle = "Question.";
var reply = app.response("What logical page do you wish to begin on?",
			                          dialogTitle);

var dialogTitle = "Question 2.";
var reply2 = app.response("How many pages per batch?",
			                          dialogTitle);

var dialogTitle = "Question 3.";
var reply3 = app.response("What increment do you wish to use? (1 for every batch, 2 for every other batch)",
			                          dialogTitle);

var newName = this.path;
var filename = newName.replace(".pdf","_NEW.pdf");

app.beginPriv();
var newDoc = app.newDoc();
app.endPriv();

var i = reply - 1;
var newPagenum = 0;
var totalPages = this.numPages - reply;
   while (i < totalPages)
   {
     // copy at batch increment
     i2 = 0;
     while (i2 < reply2)
     {
        if (i < this.numPages)
	{
           newDoc.insertPages({ nPage:newPagenum , cPath:this.path, nStart:i, nEnd:i });
           i2++;
	   i++;
	   newPagenum++;
	}
     }
     // skip at batch increment
     i2 = 0;
     while (i2 < reply2)
     { i2++; i++; }
   }

   if (newDoc.numPages > 1)
      {
	  newDoc.deletePages(0);  // this gets rid of the page that was created with the newDoc call.
      }

}
)

// add the menu item
app.addMenuItem({
     cName: "CarbonCopyJS",     // this is the internal name used for this menu item
     cUser: "Carbon Copy",       // this is the label that is used to display the menu item
     cParent: "Document",              // this is the parent menu. The file menu would use "File"
     cExec: "ProcessCarbonCopy()",  // this is the JavaScript code to execute when this menu item is selected
     cEnable: "event.rc = (event.target != null);",       // when should this menu item be active?
     nPos: 0
});
