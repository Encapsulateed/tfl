class Stack<T> {
  List<T> _items = [];

  Stack();

  Stack.fromList(List<T> items) {
    _items = List.from(items);
  }
  // Проверка, пуст ли стек
  bool isEmpty() {
    return _items.isEmpty;
  }

  // Получение размера стека
  int size() {
    return _items.length;
  }

  // Добавление элемента в стек
  void push(T item) {
    _items.add(item);
  }

  // Удаление и возврат элемента из стека
  T pop() {
    if (isEmpty()) {
      throw StateError("Stack is empty");
    }
    T poppedItem = _items.removeLast();
    return poppedItem;
  }

  // Получение элемента на вершине стека без удаления
  T peek() {
    if (isEmpty()) {
      throw StateError("Stack is empty");
    }
    return _items.last;
  }

  List<T> toList() {
    return List.from(_items);
  }

  Stack<T> copyStack() {
    List<T> stackList = List.from(this.toList());
    return Stack<T>.fromList([...stackList]);
  }
}
