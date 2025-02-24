import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';

import '../models/product.dart';

import 'pocketbase_client.dart';

class ProductsService {
  String _getFeaturedImageUrl(PocketBase pb, RecordModel productModel) {
    final featuredImageName = productModel.getStringValue('featuredImage');
    return pb.files.getUrl(productModel, featuredImageName).toString();
  }

  Future<Product?> addProduct(Product product) async {
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb.authStore.record!.id;

      final productModel = await pb.collection('products').create(
        body: {
          ...product.toJson(),
          'userId': userId,
        },
        files: [
          http.MultipartFile.fromBytes(
            'featuredImage',
            await product.featuredImage!.readAsBytes(),
            filename: product.featuredImage!.uri.pathSegments.last,
          ),
        ],
      );

      return product.copyWith(
        id: productModel.id,
        imageUrl: _getFeaturedImageUrl(pb, productModel),
      );
    } catch (error) {
      return null;
    }
  }
}
