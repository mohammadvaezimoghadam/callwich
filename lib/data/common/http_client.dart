
import 'package:dio/dio.dart';

const String baseUrl = "https://api.callwich.ir/api/";
const String baseUrlImg = "https://api.callwich.ir/";

class CustomErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // به جای اینکه Dio exception بدهد، response مناسب برگردانید
    Response response;
    
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        response = Response(
          requestOptions: err.requestOptions,
          statusCode: 408,
          data: {
            'success': false,
            'message': 'زمان اتصال به سرور به پایان رسید',
            'error': 'TIMEOUT'
          },
        );
        break;
        
      case DioExceptionType.connectionError:
        response = Response(
          requestOptions: err.requestOptions,
          statusCode: 503,
          data: {
            'success': false,
            'message': 'خطا در اتصال به سرور',
            'error': 'CONNECTION_ERROR'
          },
        );
        break;
        
      case DioExceptionType.badResponse:
        // اگر سرور response داده ولی status code نامناسب است
        response = Response(
          requestOptions: err.requestOptions,
          statusCode: err.response?.statusCode ?? 400,
          data: err.response?.data ?? {
            'success': false,
            'message': 'خطا در پاسخ سرور',
            'error': 'BAD_RESPONSE'
          },
        );
        break;
        
      case DioExceptionType.cancel:
        response = Response(
          requestOptions: err.requestOptions,
          statusCode: 499,
          data: {
            'success': false,
            'message': 'درخواست لغو شد',
            'error': 'CANCELLED'
          },
        );
        break;
        
      default:
        response = Response(
          requestOptions: err.requestOptions,
          statusCode: 500,
          data: {
            'success': false,
            'message': 'خطای نامشخص رخ داد',
            'error': 'UNKNOWN_ERROR'
          },
        );
    }
    
    // به جای exception، response را resolve کنید
    handler.resolve(response);
  }
}

final Dio httpClient = Dio(
  BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
  ),
)
  ..interceptors.add(CustomErrorInterceptor())
  // ..interceptors.add(
  //   InterceptorsWrapper(
  //     onRequest: (options, handler) {
  //       final authInfo = AuthRepository.authChangeNotifier.value;
  //       if (authInfo != null && authInfo.accessToken.isNotEmpty) {
  //         options.headers["Authorization"] = "bearer ${authInfo.accessToken}";
  //         options.headers[""]="";
  //       }
  //       handler.next(options);
  //     },
  //   ),
  // )
  ;
