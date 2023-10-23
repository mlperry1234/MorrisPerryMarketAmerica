import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:io';







 const apiKey = '76b99147dd61464cb77bd62fb3e5ee41'; //api key used for network calls
 const webURI = 'api2.shop.com';
ThemeData appTheme =  ThemeData(  //color theme used throughout the app
    scaffoldBackgroundColor: Color.fromARGB(255, 255, 250, 186),
    colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 230, 71, 53)),
    listTileTheme: ListTileThemeData(
    textColor: Color.fromARGB(255, 0, 4, 63),
    )
  );
void main() {
  runApp(MyApp( ));
}
//Main container of the Shopping Magic app
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    theme: appTheme,
      home: LoginScreen(),     
    );
  }
}

String defaultSearchTerm = "shoes"; //default search term when opening the search screen
//Home, Account, and Search tabs
class BottomNavigation extends StatefulWidget {
  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0; 
  final List<Widget> _screens = [

    HomeScreen(), 
    SearchScreen(searchterm: defaultSearchTerm), 
    AccountScreen(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: t('home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: t('search'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: t('account'),
          ),
        ],
      ),
    );
  }
}

//Login Screen requiring email and password
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isButtonEnabled = false; 

  @override
  void initState() {
    super.initState();
    usernameController.addListener(updateButtonState);
    passwordController.addListener(updateButtonState);
  }
  void _login() async {
    await setAccountInfo("Valued Customer", usernameController.text, 500, "english"); //Defualt Name, Valued Customer, Default English language
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigation()));//open the main Navigation screen upon login
  }
  void updateButtonState() {
//check if username and password is valid
    final isEmailValid = isValidEmail(usernameController.text);
    final isPasswordValid = passwordController.text.length >= 4;
  
    setState(() {
      isButtonEnabled = isEmailValid && isPasswordValid;
    });
  }

  bool isValidEmail(String email) {

    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegex.hasMatch(email);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t('login').toString()),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Welcome to the Bonus Store App!", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              Text("Use your Bonus Points YOUR way!", style: TextStyle(fontSize: 20)),   
              SizedBox(height:20),      
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: t('emailAddress'),
                  fillColor: Colors.white
                ),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: t('password'),
                ),
              ),
              SizedBox(height: 20),              
              ElevatedButton(
                
                onPressed: isButtonEnabled ? _login: null,
                child: Text(t('login').toString()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


//Class for storing Product Categories, which will show on the Home Screen
class ProductCategories {
  final String name;
  final int productCount;
  final String id;
  final List<ProductCategories> subCategories;

  ProductCategories({
    required this.name,
    required this.id,
    required this.productCount,
    required this.subCategories,
  });

  factory ProductCategories.fromJson(Map<String, dynamic> json) {
    var subCategoriesList = json['subCategories'] as List;
    List<ProductCategories> subCategories = subCategoriesList
        .map((subcategoryJson) =>
            ProductCategories.fromJson(subcategoryJson))
        .toList();

    return ProductCategories(
      name: json['name'],
      productCount: json['productCount'],
      id: json['id'].toString(),
      subCategories: subCategories,
    );
  }
}
//get product categories from api call
Future<List<ProductCategories>> parseProductCategories() async {

  final queryParameters = {
    'publisherId': 'TEST',
    'locale': 'en_US',
    'site': 'shop',
    'shipCountry': 'US',
    'onlyMaProducts': 'false',
  };

  final Uri uri = Uri.https(webURI, '/AffiliatePublisherNetwork/v2/categories', queryParameters);

  final response = await http.get(uri, headers: {
    'api_Key': apiKey, 
  });

  if (response.statusCode == 200) {
    final jsonList = json.decode(response.body)["categories"] as List;
    return jsonList.map((categoryJson) => ProductCategories.fromJson(categoryJson)).toList();
  } else {
    throw Exception('Failed to load product categories');
  }
}

//HomeScreen responsible for showing Product Categories
class HomeScreen extends StatefulWidget {

  HomeScreen();
  @override
  HomeScreenState createState() => HomeScreenState();
 
}

class HomeScreenState extends State<HomeScreen> {
  List<ProductCategories> productCategories= [];

  @override
  void initState() {
    super.initState();
    _getProductsCategories();
  }

  void _getProductsCategories() async {
    try {
      final productCategoriesResult = await parseProductCategories(); 
      setState(() {
        productCategories = productCategoriesResult;
      });
    } catch (e) {
      print('Error: $e');
    }
  }
    
 @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,
      home: Scaffold(
              appBar: AppBar(
           title: Text(t('home').toString()),

         actions: <Widget>[

      IconButton(
      icon: Icon(Icons.star),
      onPressed: () {
        
      },
    ),
    Center(child: Text( '${currentUser.bonusPoints} ${t("bonusPoints").toString()}')), 
    
  ],
      ),
       body: ListView(
        children: productCategories.map((category) {
          return ListTile(
            title: Text(category.name),
            onTap: () {

        
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:  (context) => SearchScreen(searchterm: category.name),
                ),
              );

              
            },
          );
        }).toList(),
      ),     

      )
    );
  }
}


//product information for each item
class ProductDetail {
  String name;
  String shortDescription;
  String largeImage;
  String id;
  double minimumPrice;

  ProductDetail({
    required this.name,
    required this.id,
    required this.shortDescription,
    required this.largeImage,
    required this.minimumPrice,
  });


  factory ProductDetail.fromJson(dynamic json) {
    return ProductDetail(
      name: json['name'],
      id: json["id"].toString(),
      shortDescription: json['shortDescription'],
      largeImage: json['image']['sizes'][0]['url'],
      minimumPrice: 12.33,
    );
  }
}

//Parsing product detail information from the api call
Future<ProductDetail>  parseProductDetail(String productId) async {

 
  final queryParameters = {'publisherId': 'TEST', 'locale': 'en_US', 'site': 'layered' , 'shipCountry': 'US'  };
  final Uri uri = Uri.https(webURI, '/AffiliatePublisherNetwork/v2/products/' + productId, queryParameters);

  final response = await http.get(uri, headers: {
    'api_Key': apiKey
  });


  if (response.statusCode == 200) {

    final Map<String, dynamic> data = json.decode(response.body);

    return ProductDetail.fromJson(data);

  } else {
    throw Exception('Failed to load product detail information');
  }
}

class ProductDetailsScreen extends StatefulWidget {
   final productId;
  ProductDetailsScreen({required this.productId});
  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}



class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController shortDescriptionController = TextEditingController();

  int bonusPointsCost = 125;//depletes this amount from Bonus Points when changes are submitted

 String productImage = "";
  final picker = ImagePicker();
  File? _pickedFile;
  //placeholder productDetail information
  ProductDetail productDetail = ProductDetail(name: "name", id:"123", shortDescription: "shortDescription", largeImage: "largeImage", minimumPrice: 22.2);
  
  @override
  void initState() {
    super.initState();
    loadProductDetail();
  }
  void loadProductDetail() async{

    productDetail = await parseProductDetail(widget.productId);
    nameController.text =  productDetail.name;
    shortDescriptionController.text = productDetail.shortDescription;

    setState(() {
        productImage = productDetail.largeImage;
    });

  }
  Future<void> _getImage() async {

//get images from device storage for replacing the product image
  PermissionStatus galleryStatus = await Permission.photos.status;


 Map<Permission, PermissionStatus> status = await [
    Permission.photos
  ].request();

 
    final pickedXFile = await picker.pickImage(source: ImageSource.gallery);

     
    if (pickedXFile != null) {
          setState(() {
            productImage = "";
            _pickedFile  = File(pickedXFile.path); //set new product image
    });
      
    }

  }

//User can edit product information and submit changes to the store

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t('productDetails').toString()),
           actions: <Widget>[

      IconButton(
      icon: Icon(Icons.star),
      onPressed: () {
        
      },
    ),
    Center(child: Text( '${currentUser.bonusPoints} ${t("bonusPoints").toString()}')), 
    
  ],      
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[

            if (_pickedFile != null)
              Image.file(_pickedFile!, width: 200, height: 200),
            if (productImage != "")
              Image.network(productImage),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getImage, //change product image
              child: Text(t('changeImage').toString()),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: t('newName')),
            ),
            TextFormField(
              controller: shortDescriptionController,
              decoration: InputDecoration(labelText: t('newDescription')),
              maxLines: null, 
            ),
            TextFormField(
              decoration: InputDecoration(labelText: t('newQuantity')),
              keyboardType: TextInputType.number,
            ),            
            TextFormField(
              decoration: InputDecoration(labelText: t('newPrice')),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Text("${t("use").toString()} ${bonusPointsCost} ${t("bonusPoints")} "),
            SizedBox(height: 16),            
            ElevatedButton( // if user has enough bonus points, enable saveChanges button
              onPressed: (currentUser.bonusPoints > 0) ? () async {
                //subtract point cost from bonus points and store changes
             setAccountInfo("Valued Customer", currentUser.email, currentUser.bonusPoints - bonusPointsCost, currentUser.language);
             snackBar(t("newItemSet").toString() , context);
                  await Future.delayed(Duration(seconds: 2)); //delay for showing pop up message
              //code for submitting changes would be called here
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:  (context) => BottomNavigation(),
                ),
              );
              }: null,
              child: Text(t('saveChanges').toString()),
            ),

            
          ],
          
        ),
      ),
    );
  }
}
//pop up message handler
void  snackBar (String message, BuildContext context) { 

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  content:  Text(message)
));
}


//class for storing the general products within a category, which shows up on the Search screen
class ProductGeneral {
  final String name;
  final String id;
  final double minimumPrice;
  final String shortDescription;
  final String mediumImage;

  ProductGeneral({
    required this.name,
    required this.id,
    required this.minimumPrice,
    required this.shortDescription,
    required this.mediumImage,
  });

  factory ProductGeneral.fromJson(Map<String, dynamic> json) {
    final imageList = json['image']['sizes'] as List;
    final mediumImage = imageList.isNotEmpty ? imageList[2]['url'] : '';

    return ProductGeneral(
      name: json['name'],
      id: json['id'].toString(),
      minimumPrice: json['minimumPrice'].toDouble(),
      shortDescription: json['shortDescription'],
      mediumImage: mediumImage,
    );
  }
}

//parsing information from the products api call
Future<List<ProductGeneral>> parseProductsGeneral(String searchTerm) async {

  final queryParameters = {
    'publisherId': 'TEST',
    'locale': 'en_US',
    'site': 'shop',
    'shipCountry': 'US',
    'term': searchTerm,
    'onlyMaProducts': 'false',
  };

  final Uri uri = Uri.https(webURI, '/AffiliatePublisherNetwork/v2/products', queryParameters);

  final response = await http.get(uri, headers: {
    'api_Key': apiKey,
  });

  if (response.statusCode == 200) {

    final jsonList = json.decode(response.body)["products"] as List;
   
    return jsonList.map((categoryJson) => ProductGeneral.fromJson(categoryJson)).toList();
  } else {
    throw Exception('Failed to load products');
  }
}

//search screen which shows the products based on a selected category
class SearchScreen extends StatefulWidget {
  final searchterm;
  SearchScreen({required this.searchterm});
  @override
  _SearchScreenState createState() => _SearchScreenState();



}

class _SearchScreenState extends State<SearchScreen> {
  List<ProductGeneral> products = [];

  @override
  void initState() {
    super.initState();
  setState(() {


 _getProductsGeneral();
  });
   
  }

  void _getProductsGeneral() async {
    try {
      final retrievedProducts = await parseProductsGeneral(widget.searchterm); 
      setState(() {
        products = retrievedProducts;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(t('searchResults').toString()),
                 actions: <Widget>[

      IconButton(
      icon: Icon(Icons.star),
      onPressed: () {
        
      },
    ),
    Center(child:Text( '${currentUser.bonusPoints} ${t("bonusPoints").toString()}')), 
    
  ],
      ),
      body: ListView(
        children: products.map((product) {
          return ListTile(
            leading: Image.network(product.mediumImage),
            title: Text(product.name),
            subtitle: Text('Price: \$${product.minimumPrice.toStringAsFixed(2)}'),

            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:  (context) => ProductDetailsScreen(productId: product.id),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}


//user infomration based on login info, language settings, and bonus points
class User {
  final String id;
  final String name;
  final String email;  
  final int bonusPoints;
  final String language;

  User({required this.id, required this.name, required this.bonusPoints, required this.email, required this.language});
}
User currentUser =  User(id:"0", name:"Valued Customer", bonusPoints:500, email:"email@address.com", language: "english");


//saving and getting account information within storage
Future<void> setAccountInfo(String name, String email, int bonusPoints, String language) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('name', name);
  await prefs.setString('email', email);
  await prefs.setInt('bonusPoints', bonusPoints);
  await prefs.setString('language', language);

  currentUser =  User(id:"0", name:name, bonusPoints:bonusPoints, email:email, language:language);

}


Future<Map<String, dynamic>> getAccountInfo() async {
  final prefs = await SharedPreferences.getInstance();
  final name = prefs.getString('name');
  final email = prefs.getString('email');
  final bonusPoints = prefs.getInt('bonusPoints');

  return {
    'name': name,
    'email': email,
    'bonusPoints': bonusPoints,
  };
}
class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String userName = ''; 
  String userEmail = '';
  int bonusPoints = 0;
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    _loadUserData(); 
  }


  Future<void> _loadUserData() async {

    final accountInfo =await  getAccountInfo();
    setState(() {
      userName = accountInfo["name"]; 
      userEmail = accountInfo["email"]; 
      bonusPoints = accountInfo["bonusPoints"]; 
      isChecked =  accountInfo["language"] == "spanish"; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text(t('account').toString()),
      ),
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: <Widget>[
      IconButton( onPressed: () => {},
      icon: Icon(Icons.person), iconSize: 122, color: Colors.black,),
            SizedBox(height: 20),
            Text(
              'Name: ${userName}',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Email: ${userEmail}',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Bonus Points: ${currentUser.bonusPoints}',
              style: TextStyle(fontSize: 20),

            ),
             SizedBox(height: 20),
            Center(child:Column(children:[Checkbox(
              
              value: isChecked,
              onChanged: (bool? newValue) async {
                if( newValue ?? false){//checkbox which toggles language setting

                   await setAccountInfo(userName, userEmail, currentUser.bonusPoints, "spanish");
                } else{

                  await setAccountInfo(userName, userEmail, currentUser.bonusPoints, "english");  
                }
                setState(() {
                  isChecked = newValue ?? false;

                });
              },
            ), Text(t("lang").toString(), style: TextStyle(fontSize: 20))])),
            SizedBox(height: 40),
            ElevatedButton(onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            }, child: Text(t('logOut').toString()))
        ],)     
        ),
      );
  }
}




//english translations

var en_json = {
    "emailAddress":"Email Address",
    "password":"Password",
    "logOut": "Log Out",
    "productDetails": "Product Details",
    "search": "Search",
    "bonusPoints": "Bonus Points",
    "login": "Login",
    "home": "Home",
    "account": "Account",
    "searchResults": "Search Results",
    "name": "Name",
    "changeImage": "Change Product Image",
    "saveChanges": "Send Changes",
    "newPrice": "Enter a new Price",
    "newQuantity": "Enter a new Quantity",    
    "newDescription": "Enter a new Description",
    "newItemSet": "Congratulations, your changes to this item will now be submitted!",
    "lang": "Spanish Mode",
    "use": "Use",
};

//spanish translations
var es_json = {
    "emailAddress": "Dirección de Correo Electrónico",
    "password": "Contraseña",
    "logOut": "Cerrar Sesión",
    "productDetails": "Detalles del Producto",
    "search": "Buscar",
    "bonusPoints": "Puntos de Bonificación",
    "login": "Iniciar Sesión",
    "home": "Inicio",
    "account": "Cuenta",
    "searchResults": "Resultados de Búsqueda",
    "name": "Nombre",
    "changeImage": "Cambiar Imagen del Producto",
    "saveChanges": "Guardar Cambios",
    "newPrice": "Ingrese un Nuevo Precio",
    "newQuantity": "Ingrese una Nueva Cantidad",    
    "newDescription": "Ingrese una Nueva Descripción",
    "newItemSet": "¡Felicidades, sus cambios en este artículo se enviarán ahora!",
    "use": "Usar",
    "lang": "Mode de Espanol"
};

String? t(String text){

  if(currentUser.language == "english"){
  return en_json[text];
  } else{
  return es_json[text];

  }



}