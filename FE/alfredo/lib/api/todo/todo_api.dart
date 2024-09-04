// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import '../../models/todo/todo_model.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// class TodoApi {
//   final String baseUrl = dotenv.get('TODO_API_URL');
//   TodoApi();

//   //헤더에 토큰이 필요 없는 경우
//   Map<String, String> get _headers => {
//         'Content-Type': 'application/json; charset=UTF-8',
//       };

//   // //헤더에 토큰이 필요한 경우
//   // Map<String, String> _authHeaders(String authToken) => {
//   //       ..._headers,
//   //       'Authorization': 'Bearer $authToken',
//   //     };

//   // Future<List<Todo>> createTodos(List<Todo> todos, String authToken) async {
//   //   final response = await http.post(
//   //     Uri.parse(baseUrl),
//   //     headers: _authHeaders(authToken),
//   //     body: jsonEncode(todos.map((todo) => todo.toJson()).toList()),
//   //   );
//   //   if (response.statusCode == 200) {
//   //     Iterable jsonResponse = json.decode(response.body);
//   //     return jsonResponse.map((data) => Todo.fromJson(data)).toList();
//   //   } else {
//   //     throw Exception('Failed to create todos');
//   //   }
//   // }
//   // 헤더에 토큰이 필요한 경우
//   Map<String, String> _authHeaders(String authToken) => {
//         'Content-Type': 'application/json; charset=UTF-8',
//         'Authorization': 'Bearer $authToken',
//       };

//   // 날짜별 Todo 항목 가져오기
//   Future<List<Todo>> fetchTodosByDate(DateTime date, String authToken) async {
//     final response = await http.post(
//       Uri.parse('http://10.0.2.2:8080/api/todo/bydate'),
//       headers: _authHeaders(authToken),
//       body: jsonEncode({'date': DateFormat('yyyy-MM-dd').format(date)}),
//     );

//     if (response.statusCode == 200) {
//       List<dynamic> todoJson = json.decode(response.body) as List;
//       return todoJson.map((json) => Todo.fromJson(json)).toList();
//     } else {
//       throw Exception(
//           'Failed to load todos. Status code: ${response.statusCode}, Message: ${response.body}');
//     }
//   }

//   Future<String> createTodos(List<Todo> todos, String authToken) async {
//     final response = await http.post(
//       Uri.parse(baseUrl),
//       headers: _authHeaders(authToken),
//       body: jsonEncode(todos.map((todo) => todo.toJson()).toList()),
//     );
//     if (response.statusCode == 200) {
//       // 서버 응답이 단순 문자열인 경우 바로 반환
//       return response.body;
//     } else {
//       // 에러 발생시 에러 메시지 반환
//       throw Exception(
//           'Failed to create todos. Status code: ${response.statusCode}, Message: ${response.body}');
//     }
//   }
// }

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../models/todo/todo_model.dart';

class TodoApi {
  // // 싱글톤 패턴을 위한 내부 인스턴스와 생성자
  // static final TodoApi _instance = TodoApi._internal();
  // TodoApi._internal();
  // factory TodoApi() => _instance;

  // 환경 변수에서 baseUrl을 가져옴
  final String baseUrl = dotenv.get('TODO_API_URL');

  // 토큰이 필요 없는 헤더 구성
  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=UTF-8',
      };

  // 인증 토큰이 필요한 경우 헤더 구성
  Map<String, String> _authHeaders(String authToken) => {
        ..._headers,
        'Authorization': 'Bearer $authToken',
      };

  // 날짜별 Todo 항목 가져오기
  // Future<List<Todo>> fetchTodosByDate(DateTime date, String authToken) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/bydate'),
  //     headers: _authHeaders(authToken),
  //     body:
  //         jsonEncode({'date': DateFormat('yyyy-MM-dd').format(DateTime.now())}),
  //   );

  //   if (response.statusCode == 200) {
  //     List<dynamic> todoJson = json.decode(response.body) as List;
  //     return todoJson.map((json) => Todo.fromJson(json)).toList();
  //   } else {
  //     throw Exception(
  //         'Failed to load todos. Status code: ${response.statusCode}, Message: ${response.body}');
  //   }
  // }
  Future<List<Todo>> fetchTodosList(String authToken) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: _authHeaders(authToken),
    );

    if (response.statusCode == 200) {
      // UTF-8로 디코딩
      final decodedData = utf8.decode(response.bodyBytes);
      List<dynamic> todoJson = json.decode(decodedData) as List;
      return todoJson.map((json) => Todo.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load todos. Status code: ${response.statusCode}, Message: ${response.body}');
    }
  }

  Future<List<Todo>> fetchTodosByDate(DateTime date, String authToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bydate'),
      headers: _authHeaders(authToken),
      body:
          jsonEncode({'date': DateFormat('yyyy-MM-dd').format(DateTime.now())}),
    );

    if (response.statusCode == 200) {
      // UTF-8로 디코딩
      final decodedData = utf8.decode(response.bodyBytes);
      List<dynamic> todoJson = json.decode(decodedData) as List;
      return todoJson.map((json) => Todo.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load todos. Status code: ${response.statusCode}, Message: ${response.body}');
    }
  }

  // Todo 항목 생성하기
  Future<String> createTodos(List<Todo> todos, String authToken) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: _authHeaders(authToken),
      body: jsonEncode(todos.map((todo) => todo.toJson()).toList()),
    );
    if (response.statusCode == 200) {
      // 서버 응답이 단순 문자열인 경우 바로 반환
      return response.body;
    } else {
      // 에러 발생시 에러 메시지 반환
      throw Exception(
          'Failed to create todos. Status code: ${response.statusCode}, Message: ${response.body}');
    }
  }

  // Todo 아이템의 세부 정보를 가져오는 메서드
  Future<Todo> fetchTodoById(int id) async {
    final response =
        await http.get(Uri.parse('$baseUrl/$id'), headers: _headers);

    if (response.statusCode == 200) {
      // UTF-8로 디코딩
      final decodedData = utf8.decode(response.bodyBytes);
      return Todo.fromJson(json.decode(decodedData));
    } else {
      throw Exception(
          'Failed to load todo. Status code: ${response.statusCode}, Message: ${response.body}');
    }
  }

  Future<void> updateTodo(int id, Todo todo, String authToken) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$id'),
      headers: _headers,
      body: jsonEncode(todo.toJson()),
    );

    if (response.statusCode == 204) {
      print('Update successful. Status: ${response.statusCode}');
    } else {
      print('Failed to update. Status: ${response.statusCode}');
      // print('Response body: ${response.body}');
      throw Exception('Failed to update todo');
    }
  }

  Future<void> updateTodosBySubIndexAndDate(
      String subIndex, DateTime dueDate, Todo todo, String authToken) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/updateBySubIndex'),
      headers: _authHeaders(authToken),
      body: jsonEncode(todo.toJson()),
    );

    if (response.statusCode != 204) {
      throw Exception(
          'Failed to update todos by subIndex and date. Status code: ${response.statusCode}, Message: ${response.body}');
    }
  }

  Future<void> deleteTodoById(int id) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/$id'), headers: _headers);

    if (response.statusCode == 200) {
      print('Delete successful. Status: ${response.statusCode}');
    } else {
      print('Failed to delete. Status: ${response.statusCode}');
      // print('Response body: ${response.body}');
      throw Exception('Failed to delete todo');
    }
  }

  Future<void> deleteTodoBySubIndexAndDate(
      String subIndex, DateTime dueDate, String authToken) async {
    // URL에 쿼리 파라미터를 추가하여 구성
    final url =
        Uri.parse('$baseUrl/deleteBySubIndex').replace(queryParameters: {
      'subIndex': subIndex,
      'dueDate': DateFormat('yyyy-MM-dd').format(dueDate), // DateTime을 문자열로 변환
    });

    final response = await http.delete(
      url,
      headers: _authHeaders(authToken), // 토큰을 포함한 헤더 사용
    );

    if (response.statusCode != 204) {
      throw Exception(
          'Failed to delete todos by subIndex and date. Status code: ${response.statusCode}, Message: ${response.body}');
    }
  }

  // Future<void> updateTimeSpent(int id, int spentTime) async {
  //   final response = await http.patch(
  //     Uri.parse('$baseUrl/$id'),
  //     headers: _headers,
  //     body: jsonEncode({'spentTime': spentTime}),
  //   );

  //   if (response.statusCode == 204) {
  //     print('Update successful. Status: ${response.statusCode}');
  //   } else {
  //     print('Failed to update. Status: ${response.statusCode}');
  //     print('Response body: ${response.body}');
  //     throw Exception('Failed to update time spent');
  //   }
  // }
}
