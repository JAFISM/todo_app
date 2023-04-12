import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _taskController = TextEditingController();

  List<Map<String, dynamic>> _items = [];

  final myTodo = Hive.box('my_todo');

  @override
  void initState() {
    super.initState();
    _refreshTask();
  }

  void _refreshTask() {
    final data = myTodo.keys.map((key) {
      final item = myTodo.get(key);
      return {
        "key": key,
        "task": item["task"],
        "completed": item['completed'] ?? false
      };
    }).toList();
    setState(() {
      _items = data.reversed
          .toList(); // we use 'reversed' to sort item in order from the latest to oldest
     // print(_items.length);
    });
  }

  Future<void> _createItem(Map<String, dynamic> newTask) async {
    await myTodo.add(newTask);
    _refreshTask();
    //print('amount ${myTodo.length}');
  }

  Future<void> _updateItem(int itemKey, Map<String, dynamic>task) async {
    await myTodo.put(itemKey,task);
    _refreshTask();
  }

  Future<void> _deleteItem(int itemKey) async {
    await myTodo.delete(itemKey);
    _refreshTask();
  }

  void _showForm(_, int? itemKey) {
    if (itemKey != null) {
      final existingItem =
          _items.firstWhere((element) => element['key'] == itemKey);
      _taskController.text = existingItem['task'];
    }
    showModalBottomSheet(
      backgroundColor: const Color(0xFFEEEFF5),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      isScrollControlled: true,
      elevation: 5,
      context: context,
      builder: (_) {
        return Container(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 15,
              left: 15,
              right: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _taskController,
                decoration: const InputDecoration(
                    hintText: 'add your task', border: InputBorder.none),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  onPressed: () async {
                    if (itemKey == null) {
                      _createItem({"task": _taskController.text});
                    }
                    if (itemKey != null) {
                      _updateItem(itemKey, {
                        'task': _taskController.text.trim(),
                      });
                    }
                    _taskController.text = '';
                    Navigator.of(context).pop();
                  },
                  child: Text(itemKey == null ? 'create task' : 'update')),
              const SizedBox(
                height: 30,
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ToDo App",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: ListView.separated(
        itemCount: _items.length,
        padding: const EdgeInsets.only(left: 10, right: 10, top: 25),
        itemBuilder: (_, index) {
          final currentItem = _items[index];
          final isCompleted = currentItem["completed"] ?? false;
          return ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            leading: Checkbox(
              value: isCompleted!,
              onChanged: (bool? value) {
                _updateItem(currentItem['key'], {
                  'key': currentItem['key'],
                  'completed': value ?? false,
                  'task': currentItem['task'],
                });
              },
            ),
            title:isCompleted? Text(currentItem["task"],style: const TextStyle(decoration: TextDecoration.lineThrough),):Text(currentItem["task"]),
            tileColor: Colors.indigo.withOpacity(0.3),
            trailing: Wrap(
              spacing: 10,
              children: [
                GestureDetector(
                  onTap: () {
                    _showForm(_, currentItem['key']);
                  },
                  child: const Icon(
                    Icons.edit,
                    color: Colors.indigo,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _deleteItem(currentItem['key']);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("An item has been deleted")));
                  },
                  child: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                )
              ],
            ),
          );
        },
        separatorBuilder: (_, index) => const SizedBox(height: 10),
      ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width / 2.5,
        child: FloatingActionButton(
          isExtended: true,
          onPressed: () => _showForm(context, null),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("Add Task",style: TextStyle(fontWeight: FontWeight.bold),),
            ],
          ),
        ),
      ),
    );
  }
}
