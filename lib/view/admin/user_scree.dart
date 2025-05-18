import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today",
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Good Morning, Dear",
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium,
                        )
                      ],
                    ),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.blueAccent,
                        // image: DecorationImage(
                        //   image: AssetImage("/"),
                        //   fit: BoxFit.cover,
                        // ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    enabled: false,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        25,
                      ),
                      borderSide: BorderSide.none,
                    ),
                    prefix: const Icon(
                      Iconsax.search_favorite,
                      size: 30,
                      color: Colors.black,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Departments",
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    departmentCard(
                        "Coordinators", 88, "coord", Colors.orangeAccent, "👱"),
                    departmentCard(
                        "Students", 88, "stud", Colors.blueAccent, "👱"),
                    departmentCard(
                        "Coordinators", 88, "coord", Colors.redAccent, "👱"),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "You recently worked with",
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                children: [
                  usersWorkedWith("Sam Smith", "assets", Colors.blueAccent,
                      "Frontend Developer"),
                  usersWorkedWith("Sam Smith", "assets", Colors.blueAccent,
                      "Frontend Developer"),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget usersWorkedWith(
      String name, String image, Color color, String jobTitle) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 20,
      ),
      child: InkWell(
        onTap: () {
          String _job;
          if (color == Colors.blueAccent) {
            _job = "Developer";
          } else if (color == Colors.redAccent) {
            _job = "Engineer";
          } else {
            _job = "Designer";
          }

          // Navigator.push(context, MaterialPageRoute(builder: (context)=>WorkerDetailsScreen()));
        },
        child: Container(
          width: double.infinity,
          height: 90,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: ListTile(
              title: Text(
                name,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              subtitle: Text(
                jobTitle,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              trailing: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Center(
                    child: Icon(
                      Iconsax.edit,
                    ),
                  ),
                ),
              ),
              leading: Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    15,
                  ),
                  color: Colors.blueAccent,
                  // image: DecorationImage(
                  //   image: AssetImage(image),
                  //   fit: BoxFit.cover,
                  // ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget departmentCard(
      String name, int number, String title, Color color, String emoji) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                number.toString() + " " + title,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
