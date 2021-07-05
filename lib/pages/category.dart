import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:todo_flutter_app/blueprint/category.dart';
import 'package:todo_flutter_app/global/jwtVerifyFunction.dart';
import 'package:todo_flutter_app/pages/eachCategory.dart';
import 'package:http/http.dart' as http;
import 'package:todo_flutter_app/global/serverIp.dart' as globalConstants;
import 'package:todo_flutter_app/pages/login.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:todo_flutter_app/global/storage.dart' as globalStorage;

class Category extends StatefulWidget {
  const Category({Key? key}) : super(key: key);

  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  bool _isLoading = false;
  bool _refreshPage = false;
  bool _emailset = false;
  bool _getAllcategory = false;
  bool isServerError = false;
  final TextStyle fontSize = TextStyle(fontSize: 17);
  static ScrollController _controller = ScrollController();
  late var result;
  late var decodedToken;
  List<CategoryBlueprint> categories = [];
  String serverError = "";
  void addCategory() async {
    result = await Navigator.pushNamed(context, "/addCategory");
    if (result != null) {
      setState(() {
        categories.add(CategoryBlueprint(
            id: result[0],
            groupId: "HardCode GroupId",
            category: result[1],
            c: 0,
            nc: 0));
      });
    }
  }

  Future<void> getAllCategories() async {
    // if (this.mounted) {
    try {
      var complete, notcomplete;
      var headers = await globalConstants.tokenRead();
      var result = await http.get(
          Uri.parse("${globalConstants.severIp}/category/all"),
          headers: headers);
      var allCategories = jsonDecode(result.body);
      categories.removeRange(0, categories.length);
      allCategories.forEach((category) => {
            notcomplete = category['NotcompletedTodos'].length == 0
                ? 0
                : category['NotcompletedTodos'][0]['NotcompletedTodos'],
            complete = category['CompletedTodos'].length == 0
                ? 0
                : category['CompletedTodos'][0]['CompletedTodos'],
            categories.add(CategoryBlueprint(
                id: category['_id'],
                groupId: category['groupId'],
                category: category['text'],
                c: complete,
                nc: notcomplete))
          });
      setState(() {
        _getAllcategory = true;
        isServerError = false;
      });
    } catch (err) {
      print(err);
      setState(() {
        _refreshPage = false;
        isServerError = true;
        serverError = "Some Error Occured While Retreving Categories";
      });
    }
    // }
  }

  Future<void> _deleteCategory(
      CategoryBlueprint element, String categoryName, String categoryId) async {
    var result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure?'),
            content: Text("You Want to Delete Category $categoryName ?"),
            actions: <Widget>[
              TextButton(
                child: Text('NO'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text('YES'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        });
    if (result) {
      var headers = await globalConstants.tokenRead();
      var deleteRequest = await http.delete(
          Uri.parse("${globalConstants.severIp}/category/delete/$categoryId"),
          headers: headers);
      if (jsonDecode(deleteRequest.body)['success'] != null) {
        final snackBar = SnackBar(
          content: Text(
            'Deletion Of $categoryName Successfull',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        );
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          categories.remove(element);
        });
      }
      // else if(jsonDecode(deleteRequest.body)['err']!=null){

      // }
    }
  }

  void checkLogin() async {
    bool result = await validLogin();
    print(result);
    if (result) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute<void>(builder: (BuildContext context) => Login()),
          (route) => false);
    }
  }

  void setUsername() async {
    var result = await globalStorage.storage.read(key: "jwt");
    decodedToken = JwtDecoder.decode(result.toString());
    setState(() {
      _emailset = true;
    });
  }

  @override
  void initState() {
    super.initState();
    checkLogin();
    setUsername();
    getAllCategories();
  }

  Widget data(element) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EachCategory(
                    element.id, element.category, element.c, element.nc),
              ));
        },
        child: Card(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 2, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Status: ${element.c}/${element.nc + element.c}",
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(element.category, style: TextStyle(fontSize: 15)),
                    IconButton(
                      onPressed: () {
                        _deleteCategory(element, element.category, element.id);
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.black54,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _emailset ? Text(decodedToken['email']) : Container(),
        centerTitle: true,
      ),
      body: isServerError
          ? Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      serverError,
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _refreshPage = true;
                      });
                      getAllCategories();
                    },
                    child: Text("Refresh Page")),
                _refreshPage ? CircularProgressIndicator() : Container()
              ],
            )
          : _getAllcategory
              ? RefreshIndicator(
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
                              style: TextStyle(
                                  fontSize: 25, color: Colors.green.shade800),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _isLoading
                              ? categories.length + 1
                              : categories.length,
                          itemBuilder: (context, index) {
                            if (categories.length == index) {
                              return Center(child: CircularProgressIndicator());
                            }
                            return data(categories[index]);
                            // return categories[index];
                          },
                        ),
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
                )
              : Center(child: CircularProgressIndicator()),
    );
  }
}
