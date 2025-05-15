
// file yg berada di dalam folder model, bisa disebut dengan data class

// biasanya data class dipresentasikan dengan bundling, dengan meng-import library Parcelize = Android Native

//ini isinya data class, plis inget
//data class adalah suatu class yg isinya model model, isisnya data data yg mau di generate
class Task {
  final String name;
  final int duration;
  final DateTime deadline;

  Task({required this.name, required this.duration, required this.deadline});

//membuat suatu turunan dari object 
//salah satu contohnya adalah function di dalam function
  //untuk membuat suatu turunan dari objek
  //salah satu contoh adalah membuat objek yang memiliki deadline yang sama
  //adalah adanya function di dalam function

  @override
  String toString(){
    return "Task{name: $name, duration: $duration, deadline: $deadline}";
  }
}
