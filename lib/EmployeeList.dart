import 'dart:developer';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:responsive_sizer/responsive_sizer.dart';

class EmployeeList extends StatefulWidget {
  const EmployeeList({super.key});

  @override
  State<EmployeeList> createState() => _EmployeeListState();
}

class _EmployeeListState extends State<EmployeeList> {
  late Future<List<Employee>> _employees;

  Future<List<Employee>> fetchEmployees() async {
    final response = await http.get(
        Uri.parse('https://mocki.io/v1/3a4b56bd-ad05-4b12-a181-1eb9a4f5ac8d'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<Employee> employees = [];
      log("data", error: data);
      data.forEach((employeeData) {
        Employee employee = Employee(
          id: employeeData['id'],
          name: employeeData['name'],
          email: employeeData['email'],
          phone: employeeData['phone'],
          managerName: '', 
          subordinates: [], 
          backgroundColor: _getColorFromName(employeeData['backgroundColor']),
          parentId: employeeData['parentId'] ?? -1,
        );

        employees.add(employee);
      });

      employees.forEach((employee) {
        if (employee.id != 1) {
          final manager =
              employees.firstWhere((e) => e.id == employee.parentId);
          employee.managerName = manager.name;
          manager.subordinates.add(employee);
        }
      });

      return employees
          .toList(); 
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    _employees = fetchEmployees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CenteredMessage(
      message:
          'Sorry Unfortunately I Saw the Invitation on 16-11-2023 so I have to make UI. Also, if I got more time I will add this.',
    ),
            ))
        },
        tooltip: ' New Employee',
        child: const Icon(
          Icons.person_add_alt_1_rounded,
          color: Colors.blueAccent,
        ),
      ),
      appBar: AppBar(
        title: Text('Employee Profiles'),
        backgroundColor: const Color.fromARGB(255, 8, 155, 223),
      ),
      body: FutureBuilder<List<Employee>>(
        future: _employees,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return EmployeeCard(employee: snapshot.data![index]);
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          return Center(
            child: LoadingIndicator(),
          );
        },
      ),
    );
  }

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'brown':
        return Colors.brown;
      case 'orange':
        return Colors.orange;
      case 'grey':
        return Colors.grey;
      case 'pink':
        return Colors.pink;
      case 'black':
        return Colors.black;
      case 'purple':
        return Colors.purple;
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'white':
        return Colors.white;

      default:
        return Colors
            .transparent; // Return a default color if the name doesn't match
    }
  }
}

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 50.0, // Adjust width and height to fit your design
        height: 50.0,
        child:  CircularProgressIndicator(
          strokeWidth: 4.0, // Adjust the thickness of the indicator
          valueColor: AlwaysStoppedAnimation<Color>(
              Colors.blue), // Set the color of the indicator
        ),
      ),
    );
  }
}

class Employee {
  final int id;
  final String name;
  final String email;
  final String phone;
  String managerName;
  final List<Employee> subordinates;
  final Color backgroundColor;
  final int parentId;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.managerName,
    required this.subordinates,
    required this.backgroundColor,
    required this.parentId,
  });
}

class EmployeeCard extends StatelessWidget {
  final Employee employee;

  EmployeeCard({required this.employee});

  Color getTextColorBasedOnBackground(Color backgroundColor) {
  final perceivedLuminance = backgroundColor.computeLuminance();
  return perceivedLuminance > 0.5 ? Colors.black : Colors.white;
}

  @override
  Widget build(BuildContext context) {
    return Card(
      color: employee.backgroundColor,
      child: ListTile(
        title: Text(employee.name,style: GoogleFonts.dmSans(
                    fontSize: 18.sp,
                    color: getTextColorBasedOnBackground(employee.backgroundColor),
                    fontWeight: FontWeight.w900,
                  ),),
        subtitle: Text(employee.email,style: GoogleFonts.dmSans(
                    fontSize: 13.sp,
                    color: getTextColorBasedOnBackground(employee.backgroundColor),
                    fontWeight: FontWeight.w900,
                  ),),
        trailing: Text(employee.phone,style: GoogleFonts.dmSans(
                    fontSize: 18.sp,
                    color: getTextColorBasedOnBackground(employee.backgroundColor),
                    fontWeight: FontWeight.w900,
                  ),),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmployeeDetails(employee: employee),
            ),
          );
        },
      ),
    );
  }
}

class EmployeeDetails extends StatelessWidget {
  final Employee employee;

  EmployeeDetails({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' Employee Details'),
        backgroundColor: const Color.fromARGB(255, 8, 155, 223),
      ),
      body: Container(
      
        padding: EdgeInsets.only(left: 15.w,right: 15.w, top: 10.h),
        decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFdad7cd), Color(0xFF8ecae6)],
            stops: [0.2, 0.8],
        ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ' ${employee.name}',
              style: GoogleFonts.dmSans(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color.fromARGB(255, 8, 155, 223)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.email_outlined,color:const Color.fromARGB(255, 8, 155, 223),size: 25.sp,semanticLabel: 'Email',),
                Text(' ${employee.email}',
                    style: GoogleFonts.dmSans(
                      fontSize: 15.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    )),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone,color:const Color.fromARGB(255, 8, 155, 223),size: 25.sp,),
                Text(' ${employee.phone}', style: GoogleFonts.dmSans(
                    fontSize: 15.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.person,color: const Color.fromARGB(255, 8, 155, 223),size: 25.sp,),
                Text(
                  'Manager: ${employee.managerName}',
                  style: GoogleFonts.dmSans(
                      fontSize: 15.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.group,color: const Color.fromARGB(255, 8, 155, 223),size: 25.sp,),
                Text(
                  'Subordinates:',
                  style: GoogleFonts.dmSans(
                      fontSize: 15.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: employee.subordinates
                  .map(
                    (subordinate) => Container(
                      margin: EdgeInsets.only(left:10.w),
                      child: Row(
                        children: [
                          Icon(Icons.person_3,color:const Color.fromARGB(255, 8, 155, 223),size: 25.sp,),
                          Text(' ${subordinate.name}',style: GoogleFonts.dmSans(
                                              fontSize: 15.sp,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w900,
                                            ),),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}








class CenteredMessage extends StatelessWidget {
  final String message;

  CenteredMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
        ),
      ),
    );
  }
}
