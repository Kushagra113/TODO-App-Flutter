import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:todo_flutter_app/blueprint/category.dart';
import 'package:todo_flutter_app/global/jwtVerifyFunction.dart';
import 'package:todo_flutter_app/pages/eachCategory.dart';
import 'package:http/http.dart' as http;
import 'package:todo_flutter_app/global/serverIp.dart' as globalConstants;
import 'package:todo_flutter_app/pages/login.dart';
import 'package:todo_flutter_app/global/storage.dart' as globalStorage;
import 'package:jwt_decoder/jwt_decoder.dart';

class Category extends StatefulWidget {
  const Category({Key? key}) : super(key: key);

  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  bool _isLoading = false;
  bool _emailset = false;
  bool _getAllcategory = false;
  final TextStyle fontSize = TextStyle(fontSize: 17);
  static ScrollController _controller = ScrollController();
  late var result;
  List<CategoryBlueprint> categories = [];
  late Map<String, dynamic> decodedToken;
  String serverError = "";
  void addCategory() async {
    result = await Navigator.pushNamed(context, "/addCategory");
    print("Res" + result.toString());
    if (result != null) {
      setState(() {
        categories.add(CategoryBlueprint(id: result[0], category: result[1]));
      });
    }
  }

  Future<void> getAllCategories() async {
    print(globalConstants.severIp);
    try {
      var result =
          await http.get(Uri.parse("${globalConstants.severIp}/category/all"));
      var allCategories = jsonDecode(result.body);
      categories.removeRange(0, categories.length);
      allCategories.forEach((category) => {
            categories.add(CategoryBlueprint(
                id: category['_id'], category: category['text']))
          });
      setState(() {
        _getAllcategory = true;
      });
    } catch (err) {
      setState(() {
        serverError = "Some Error Occured While Retreving Categories";
      });
    }
  }

  void checkLogin() async {
    bool result = await validLogin();
    if (result) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute<void>(builder: (BuildContext context) => Login()),
          (route) => false);
    }
  }

  @override
  void initState() {
    super.initState();
    checkLogin();
    getAllCategories();
  }

  Widget data(element) {
    return GestureDetector(
        onTap: () {
          // testRequest();
          // print(element.id);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    EachCategory(element.id, element.category),
              ));
        },
        child: Card(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      element.category,
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _emailset
            ? Text(" ${decodedToken['email']} Page")
            : Text("Category"),
      ),
      body: RefreshIndicator(
        onRefresh: getAllCategories,
        child: SingleChildScrollView(
          controller: _controller,
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
              child: Column(
            children: <Widget>[
              Center(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Text(
                    "Categories",
                    style:
                        TextStyle(fontSize: 25, color: Colors.green.shade800),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount:
                    _isLoading ? categories.length + 1 : categories.length,
                itemBuilder: (context, index) {
                  if (categories.length == index) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return data(categories[index]);
                  // return categories[index];
                },
              ),
              // _getAllcategory : Center(child: CircularProgressIndicator()),
              Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FloatingActionButton(
                      onPressed: () {
                        addCategory();
                      },
                      child: Icon(Icons.add),
                    ),
                  )),
            ],
          )),
        ),
      ),
    );
  }
}
