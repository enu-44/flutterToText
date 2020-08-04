class ResponseApi {
  bool isSuccess;
  String message;
  dynamic result;

  ResponseApi({
    this.isSuccess,
    this.message,
    this.result,
  });

  static ResponseApi getResponseStatusCode({statusCode, login = false}) {
    if (statusCode > ResultCode.code500) {
      return ResponseApi(
          isSuccess: false, message: "Error en la conexion, con el servidor");
    }

    if (statusCode == ResultCode.code400) {
      return ResponseApi(
          isSuccess: false, message: "Error: argumento de método no válido");
    }

    if (statusCode == ResultCode.code401) {
      if (login) {
        return ResponseApi(isSuccess: false, message: "Contraseña incorrecta");
      } else {
        return ResponseApi(
            isSuccess: false, message: "Autorizacion invalidada");
      }
    }

    if (statusCode == ResultCode.code404) {
      return ResponseApi(
          isSuccess: false, message: "no se encontraron resultados");
    }

    if (statusCode > ResultCode.code400) {
      return ResponseApi(isSuccess: false, message: "Error desconocido");
    }

    return ResponseApi(isSuccess: true, message: "Ok");
  }
}

class ResultCode {
  static int code200 = 200;
  static int code201 = 201;
  static int code204 = 204;
  static int code400 = 400;
  static int code401 = 401;
  static int code404 = 404;
  static int code500 = 500;
}
