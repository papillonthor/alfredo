import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../controller/todo/todo_controller.dart';
import '../../models/todo/todo_model.dart';
import '../../provider/todo/todo_provider.dart';
import '../../provider/achieve/achieve_provider.dart';

class TodoCreateScreen extends ConsumerStatefulWidget {
  const TodoCreateScreen({super.key});

  @override
  _TodoCreateScreenState createState() => _TodoCreateScreenState();
}

class _TodoCreateScreenState extends ConsumerState<TodoCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  String todoTitle = '';
  String? todoContent = '';
  DateTime dueDate = DateTime.now();
  String? url = '';
  String? place = '';

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)), // 90일 후까지 선택 가능
    );
    if (picked != null && picked != dueDate) {
      setState(() {
        dueDate = picked;
      });
    }
  }

  void _submitTodo() async {
    if (_validateForm()) {
      _formKey.currentState!.save();
      final TodoController controller = ref.read(todoControllerProvider);
      final newTodo = Todo(
        todoTitle: todoTitle,
        todoContent: todoContent,
        dueDate: dueDate,
        url: url,
        place: place,
      );
      try {
        await controller.createTodos([newTodo]);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('할 일을 생성했습니다.')));

        // 업적 체크 메서드 호출
        final achieveController = ref.read(achieveControllerProvider);
        await achieveController.checkTotalTodoAchieve();

        Navigator.pushReplacementNamed(context, '/main');
      } catch (error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('할 일 생성에 실패했습니다: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E9E9), // 배경 색상 설정
      appBar: AppBar(
        title: const Text("할 일 생성"),
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(labelText: '제목'),
              onSaved: (value) => todoTitle = value ?? '',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '제목을 입력해주세요';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: '내용'),
              onSaved: (value) => todoContent = value,
              maxLines: 3,
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text('날짜: ${DateFormat('yyyy-MM-dd').format(dueDate)}'),
              onTap: () => _selectDueDate(context),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'URL'),
              onSaved: (value) => url = value,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: '장소'),
              onSaved: (value) => place = value,
            ),
            ElevatedButton(
              onPressed: _submitTodo,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D2338),
                foregroundColor: Colors.white,
              ),
              child: const Text('할 일 추가'),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateForm() {
    return _formKey.currentState!.validate();
  }
}
