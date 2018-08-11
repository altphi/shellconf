Test = app.trustedFunction(function()
{
var d = this.dataObjects;
console.println("length of DataObjects = " + d.length);
for (var i = 0; i < d.length; i++)
console.show();// console.clear();
console.println("DataObject[" + i + "]=" + d[i].name);
}
)

app.addMenuItem({
     cName: "TestJS",
     cUser: "Test",
     cParent: "Edit",
     cExec: "Test()",
     cEnable: "event.rc = (event.target != null);",
     nPos: 0
});
