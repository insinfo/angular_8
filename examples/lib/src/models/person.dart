class Person {
  int id;
  String name;
  int age;

  Person({
    required this.id,
    required this.name,
    required this.age,
  });

  static Person getNew() {
    return Person(id: -1, name: '', age: 0);
  }

  factory Person.fromPerson(Person p) {
    return Person(id: p.id, name: p.name, age: p.age);
  }

  void fromPerson(Person p) {
    id = p.id;
    name = p.name;
    age = p.age;
  }

  Person clone() {
    return Person.fromPerson(this);
  }

  @override
  String toString() {
    return 'Person(id: $id, name: $name, age: $age)';
  }
}
