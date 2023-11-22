import 'package:example/src/models/person.dart';

int _serialId = -1;

class FakePersonService {
  List<Person> _people = [];

  void add(Person newPerson) {
    _serialId++;
    final clonePerson = newPerson.clone();
    clonePerson.id = _serialId;   
    _people.add(clonePerson);
  }

  void remove(Person person) {
    _people.removeWhere((p) => p.id == person.id);
  }

  void update(Person person) {
    final people = _people.where((p) => p.id == person.id);
    if (people.isEmpty) {
      throw Exception('this person not exist');
    }
    people.first.fromPerson(person);
  }

  List<Person> getAll() {
    return _people;
  }
}
