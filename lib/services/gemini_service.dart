
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:schedule_generator/models/task.dart';

class GeminiService {

  //itu link nya kita ambil dari gemini api studio
  //untuk gerbang awal antara client dan server
  //client itu context nya code kita
  //sebuah objek yg nge consume sesuatu
  //client --> aplikasi yg di deploy
  //server --> si gemini api

  //kalo dia static ditandai dengan underscro di depanya
  static const String _baseUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";
  
  final String apiKey;

  //ini adalah sebauh ternary operator untuk memastikan apakah nilai dari API_KEY tersedia, atu kosong
  //sebelum titik dua, ada kondisinya, setelah itu adalah nilai yang terpenuhi, lalu kalo nilainya false
  GeminiService() : apiKey = dotenv.env["GEMINI_API_KEY"] ?? "" {
    //ini adalah sebuah pernyataan untuk memastikan bahwa API_KEY tidak kosong
    if (apiKey.isEmpty) {
      throw ArgumentError("Please input your API Key");
    }
  }
  
  

  // logika untuk generating result dari input/prompt yg diberikan
  //yg akan di otomasi oleh ai API
  //logika dari generating result

  Future<String> generateSchedule(List<Task> tasks) async {
    
    _validateTasks(tasks);
    //ini adalah variable yg di gunakan untuk menampung prompt yang akan di eksekusi oleh ai
    //ini adalah variable yg final, yg menampung prompt request, yg digunakan untk genearate schedule
    final prompt = _buildPrompt(tasks);

    //ini try catch untuk validasi promt, apakah valid apa kaga
    //sebagai percobaan pengirim request AI
    //kalo ada request pasti ada response
    try {
      print("Prompt: \n$prompt");

      //ini pake method post
      //ini variable yg digunaka untuk response dari request ke API AI
      final response = await http.post(
        //ini adalah starting point untuk penggunaan endpoint api
        //ini di control titik aja biar ngerti, aku tau kamu sekarang ngerti rel, tapi blm tentu kedepanya ngerti T_T
        //kalo mau endpoint dari api pake uri.parse
        //yg putih putih namanya parameter
        Uri.parse("$_baseUrl?key=$apiKey"),
        headers: {
          "Content-Type" : "application/json",
        },
        //encode pancak/bearntakan/acak
        body: jsonEncode({
          "contents": [
            {
              //role disini maksudnya adalah seorang yang memberikan instruksi kepada ai
              "role": "user",
              "parts":[
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      throw ArgumentError("Failed to generate schedule: $e");
      
    }
  }
  String _handleResponse(http.Response response) {
    //jsonDecode --> bagus
    final data = jsonDecode(response.body);
    //switch adalah salah satu cabang perkondisian(kyk if else, try catch, for loops) yg berisi statement general yg dapat di eksekusi oleh berbagai macam action, tanpa harus bergantung pada single-statement yang dimiliki oleh setiap antion yg ada pada parameter
    //response.statusCod adalah staement general  yg bisa dieksekusi berbagai macam action, multipe action
    //punya multiple cases
    //statement general bakal di exsecude oleh case case
    //ini kita coba ngelempar case nya 200
    switch (response.statusCode) {
      case 200:
        //ini adalah response yang berhasil
        return data["candidates"][0]["content"]["parts"][0]["text"];
      case 404:
        //ini response yang gagal
        throw ArgumentError("Server Not Found");
      case 500:
        //ini response yang gagal
        throw ArgumentError("Internal Server Error");
      default:
        //ini response yang gagal
        throw ArgumentError("Unknown Error ${response.statusCode}");


    }
  }

  String _buildPrompt(List<Task> tasks) {
    //berfungsi untuk menyeting format tanggal dan waktu lokal ()
    initializeDateFormatting();
    final dateFormatter = DateFormat("dd mm yyyy 'pukul' hh:mm, 'id_ID'");

    final taskList = tasks.map((task) {
      final formatDeadline = dateFormatter.format(task.deadline);

      return "- ${task.name} (Duration ${task.duration} minuites, Deadline: $formatDeadline)";

    });

    //ini itu triple apostrope, untuk string multiple line
    /*
    menggunakan framework R-T-A (roles-task-action)
     */

    //ini jadi kita propmt asal jg bisa, karna ini udh ada default prompt manualnya
    return ''' 
    Saya adalah seorang siswa, dan saya memiliki daftar sebagai berikut:

    $taskList

    Tolong susun jadwal yang optimal dan efesient berdasarkan tugas tersebut.
    Tolong tentukan prioritasnya berdasarkan *deadline yang paling dekat* dan *durasi tugas*.
    Tolong buatkan jadwal yang sistematis dari pagi hari, sampai malam hari.
    Tolong pastikan semua tugas dapat selesai sebelum deadline.

    Tolong buatkan output jadwal dalam format list per jam, misalnya:
    - 07:00 - 08:00: Tugas (tugas bersih bersih, melaksanakan tugas kamar)
    ''';
  }

  void _validateTasks(List<Task> tasks) {
    //ini merupakan bentuk dari single statement dari if-else condition
    if (tasks.isEmpty) throw ArgumentError("Please input your tasks before generating schedule");
    
  }
}