class Urls {
//Live
  static const serviceUrl = "https://service.clontalk.com";

  //Test
  //static const serviceUrl = "http://localhost:8090";

//products Urlsஃ
  static const productMappingUrl = '$serviceUrl/products'; // controller mapping
  static const fetchProducts = '$productMappingUrl/getproducts';
  static const fetchProductById = "$productMappingUrl/getproductbyid";
  static const slug = "$productMappingUrl/productname";
  static const saveProduct = "$productMappingUrl/save";
//order Urls
  static const orderMappingUrl = '$serviceUrl/order'; // controller mapping
  static const createOrder = '$orderMappingUrl/create';
  static const fetchOrder = '$orderMappingUrl/fetch';
  static const cancelOrder = '$orderMappingUrl/cancelorder';
  static const paymentResponse = '$orderMappingUrl/paymentresponse';

//User Urls
  static const userMappingUrl = '$serviceUrl/user'; // controller mapping
  static const saveUser = '$userMappingUrl/save';

//Auth Urls
  static const authMappingUrl = '$serviceUrl/auth';
  static const authRegister = '$authMappingUrl/register';
  static const authLogin = '$authMappingUrl/login';
  static const authRefresh = '$authMappingUrl/refresh';
  static const getFirebaseToken = '$authMappingUrl/getFirebaseToken';
}
