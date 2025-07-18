class Urls {
//Live
  static const serviceUrl = "https://service.clontalk.com";

  //Test
  // static const serviceUrl = "http://localhost:8090";

//products Urls
  static const productMappingUrl = '$serviceUrl/products'; // controller mapping
  static const fetchProducts = '$productMappingUrl/getproducts';
}
