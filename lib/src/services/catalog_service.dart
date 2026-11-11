import '../core/api_response.dart';
import '../core/http_client.dart';
import '../models/catalog_models.dart';

/// WhatsApp Business Product Catalog service.
class CatalogService {
  final OpenWaHttpClient _client;

  CatalogService(this._client);

  /// Retrieves full product catalog of a WhatsApp business account.
  Future<ApiResponse<List<Product>>> getCatalog(String businessJid) async {
    return _client.get<List<Product>>(
      '/catalog/$businessJid',
      parser: (json) {
        final list = json as List<dynamic>? ?? [];
        return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }

  /// Gets single product detail by ID.
  Future<ApiResponse<Product>> getProduct(String businessJid, String productId) async {
    return _client.get<Product>(
      '/catalog/$businessJid/product/$productId',
      parser: (json) => Product.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Adds a new product item to the catalog.
  Future<ApiResponse<Product>> createProduct(Product product) async {
    return _client.post<Product>(
      '/catalog/createProduct',
      body: product.toJson(),
      parser: (json) => Product.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Deletes a product from the catalog.
  Future<ApiResponse<bool>> deleteProduct(String productId) async {
    return _client.delete<bool>(
      '/catalog/product/$productId',
      parser: (json) => json['deleted'] as bool? ?? true,
    );
  }
}
