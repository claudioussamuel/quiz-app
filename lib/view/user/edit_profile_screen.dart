import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quizeapp/service/user/user.dart';

import '../../service/auth/bloc/auth_bloc.dart';
import '../../service/auth/bloc/auth_event.dart';
import '../../service/select_image/bloc/select_image_bloc.dart';
import '../../service/select_image/bloc/select_image_event.dart';
import '../../service/select_image/bloc/select_image_state.dart';
import '../../utils/constants/size.dart';
import '../../utils/device/device_utility.dart';

class EditProfileScreen extends StatefulWidget {
  final UserInfo userInfo;
  const EditProfileScreen({
    super.key,
    required this.userInfo,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController city;
  late TextEditingController firstName;
  late TextEditingController profession;
  late TextEditingController phoneNumber;
  late TextEditingController surname;
  late TextEditingController address;
  late TextEditingController institution;
  late TextEditingController tertiary;

  late TextEditingController dateGraduationController;
  late TextEditingController email;

  final _formKey = GlobalKey<FormState>();

  List<String> titleType = [
    "Mr",
    "Mrs",
    "Miss",
    "Dr",
    "Ing",
    "Hon",
    "Prof",
    "Rev"
  ];
  String url = "";
  List<Map<String, String>> genderTypes = [
    {"value": "M", "name": "Male"},
    {"value": "F", "name": "Female"},
  ];
  late String value;
  late String title;
  late String gender;
  String selectDate = "";
  DateTime graduatedYear = DateTime.now();
  late String country;
  late String ownerUserId;
  //   // List of countries (you can expand this list as needed)
  List<String> countries = [
    "Select Country",
    "Afghanistan",
    "Albania",
    "Algeria",
    "Andorra",
    "Angola",
    "Antigua and Barbuda",
    "Argentina",
    "Armenia",
    "Australia",
    "Austria",
    "Azerbaijan",
    "Bahamas",
    "Bahrain",
    "Bangladesh",
    "Barbados",
    "Belarus",
    "Belgium",
    "Belize",
    "Benin",
    "Bhutan",
    "Bolivia",
    "Bosnia and Herzegovina",
    "Botswana",
    "Brazil",
    "Brunei",
    "Bulgaria",
    "Burkina Faso",
    "Burundi",
    "Cabo Verde",
    "Cambodia",
    "Cameroon",
    "Canada",
    "Central African Republic",
    "Chad",
    "Chile",
    "China",
    "Colombia",
    "Comoros",
    "Congo, Democratic Republic of the",
    "Congo, Republic of the",
    "Costa Rica",
    "Croatia",
    "Cuba",
    "Cyprus",
    "Czech Republic",
    "Denmark",
    "Djibouti",
    "Dominica",
    "Dominican Republic",
    "East Timor (Timor-Leste)",
    "Ecuador",
    "Egypt",
    "El Salvador",
    "Equatorial Guinea",
    "Eritrea",
    "Estonia",
    "Eswatini",
    "Ethiopia",
    "Fiji",
    "Finland",
    "France",
    "Gabon",
    "Gambia",
    "Georgia",
    "Germany",
    "Ghana",
    "Greece",
    "Grenada",
    "Guatemala",
    "Guinea",
    "Guinea-Bissau",
    "Guyana",
    "Haiti",
    "Honduras",
    "Hungary",
    "Iceland",
    "India",
    "Indonesia",
    "Iran",
    "Iraq",
    "Ireland",
    "Israel",
    "Italy",
    "Ivory Coast",
    "Jamaica",
    "Japan",
    "Jordan",
    "Kazakhstan",
    "Kenya",
    "Kiribati",
    "Korea, North",
    "Korea, South",
    "Kosovo",
    "Kuwait",
    "Kyrgyzstan",
    "Laos",
    "Latvia",
    "Lebanon",
    "Lesotho",
    "Liberia",
    "Libya",
    "Liechtenstein",
    "Lithuania",
    "Luxembourg",
    "Madagascar",
    "Malawi",
    "Malaysia",
    "Maldives",
    "Mali",
    "Malta",
    "Marshall Islands",
    "Mauritania",
    "Mauritius",
    "Mexico",
    "Micronesia",
    "Moldova",
    "Monaco",
    "Mongolia",
    "Montenegro",
    "Morocco",
    "Mozambique",
    "Myanmar",
    "Namibia",
    "Nauru",
    "Nepal",
    "Netherlands",
    "New Zealand",
    "Nicaragua",
    "Niger",
    "Nigeria",
    "North Macedonia",
    "Norway",
    "Oman",
    "Pakistan",
    "Palau",
    "Palestine",
    "Panama",
    "Papua New Guinea",
    "Paraguay",
    "Peru",
    "Philippines",
    "Poland",
    "Portugal",
    "Qatar",
    "Romania",
    "Russia",
    "Rwanda",
    "Saint Kitts and Nevis",
    "Saint Lucia",
    "Saint Vincent and the Grenadines",
    "Samoa",
    "San Marino",
    "Sao Tome and Principe",
    "Saudi Arabia",
    "Senegal",
    "Serbia",
    "Seychelles",
    "Sierra Leone",
    "Singapore",
    "Slovakia",
    "Slovenia",
    "Solomon Islands",
    "Somalia",
    "South Africa",
    "Spain",
    "Sri Lanka",
    "Sudan",
    "Sudan, South",
    "Suriname",
    "Sweden",
    "Switzerland",
    "Syria",
    "Taiwan",
    "Tajikistan",
    "Tanzania",
    "Thailand",
    "Togo",
    "Tonga",
    "Trinidad and Tobago",
    "Tunisia",
    "Turkey",
    "Turkmenistan",
    "Tuvalu",
    "Uganda",
    "Ukraine",
    "United Arab Emirates",
    "United Kingdom",
    "United States",
    "Uruguay",
    "Uzbekistan",
    "Vanuatu",
    "Vatican City (Holy See)",
    "Venezuela",
    "Vietnam",
    "Yemen",
    "Zambia",
    "Zimbabwe",
  ];

  String? selectedTertiary;

  // Add this variable to hold the selected university education
  String universityEducation = "First Degree"; // Default value

  @override
  void initState() {
    // _userInfoService = FirebaseCloudStorage();
    dateGraduationController = TextEditingController(
      text: widget.userInfo.yearOfGraduation_,
    );

    city = TextEditingController(text: widget.userInfo.city_);
    firstName = TextEditingController(text: widget.userInfo.firstName_);
    profession = TextEditingController(text: widget.userInfo.profession_);
    phoneNumber = TextEditingController(text: widget.userInfo.phone_);
    surname = TextEditingController(text: widget.userInfo.surname_);
    address = TextEditingController(text: widget.userInfo.address_);
    institution =
        TextEditingController(text: widget.userInfo.nameOfInstitution_);
    tertiary = TextEditingController(text: widget.userInfo.tertiary_);
    value = widget.userInfo.membership ?? "SMGhIG";
    title = widget.userInfo.title_ ?? "Mr";
    gender = widget.userInfo.gender_ ?? "M";
    country = widget.userInfo.country_ ?? "Ghana";
    ownerUserId = widget.userInfo.ownerUserId ?? "";
    email = TextEditingController(text: widget.userInfo.email_);

    selectedTertiary = [
      'University Of Ghana (Legon)',
      'Kwame Nkrumah University of Science and Technology (KNUST)',
      'University of Energy and Natural Resources (UENR)',
      'University of Mines and Technology (UMaT)',
      'University for Development Studies (UDS)',
      'Radford University College'
    ].contains(widget.userInfo.tertiary_)
        ? widget.userInfo.tertiary_
        : 'Kwame Nkrumah University of Science and Technology (KNUST)';
    universityEducation = "First Degree";
    super.initState();
  }

  @override
  void dispose() {
    city.dispose();
    firstName.dispose();
    profession.dispose();
    phoneNumber.dispose();
    surname.dispose();
    address.dispose();
    institution.dispose();
    tertiary.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = TDeviceUtils.getMode(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Edit User Info',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          centerTitle: true,
        ),
        body: Builder(builder: (context) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        2 * TSizes.buttomHeight,
                  ),
                  child: Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(TSizes.buttomHeight),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Stack(
                                  children: [
                                    BlocListener<SelectImageBloc,
                                        SelectImageState>(
                                      listener: (context, state) {
                                        if (state is SelectImageStateUploaded) {
                                          setState(() {
                                            url = state.url ?? "";
                                          });
                                        }
                                      },
                                      child: BlocBuilder<SelectImageBloc,
                                              SelectImageState>(
                                          builder: (context, state) {
                                        if (state
                                            is SelectImageStateUploading) {
                                          return const CircularProgressIndicator();
                                        } else if (state
                                            is SelectImageStateInit) {
                                          return Stack(
                                            children: [
                                              CircleAvatar(
                                                radius: 64,
                                                backgroundImage: NetworkImage(
                                                    state.url ?? ""),
                                              ),
                                              Positioned(
                                                bottom: 0,
                                                left: 80,
                                                child: IconButton(
                                                  onPressed: () {
                                                    context
                                                        .read<SelectImageBloc>()
                                                        .add(
                                                          SelectImageEventUpload(
                                                            imageSource:
                                                                ImageSource
                                                                    .gallery,
                                                          ),
                                                        );
                                                  },
                                                  icon: const Icon(
                                                    Icons.add_a_photo,
                                                    size: 40,
                                                  ),
                                                ),
                                              )
                                            ],
                                          );
                                        } else if (state
                                            is SelectImageStateUploaded) {
                                          return Stack(
                                            children: [
                                              CircleAvatar(
                                                radius: 64,
                                                backgroundImage: NetworkImage(
                                                    state.url ?? ""),
                                              ),
                                              Positioned(
                                                bottom: 0,
                                                left: 80,
                                                child: IconButton(
                                                  onPressed: () {
                                                    context
                                                        .read<SelectImageBloc>()
                                                        .add(SelectImageEventUpload(
                                                            imageSource:
                                                                ImageSource
                                                                    .gallery));
                                                  },
                                                  icon: const Icon(
                                                    Icons.add_a_photo,
                                                    size: 40,
                                                  ),
                                                ),
                                              )
                                            ],
                                          );
                                        } else {
                                          return const CircularProgressIndicator();
                                        }
                                      }),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: TSizes.spaceBtwItems,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: !dark
                                          ? Colors.white
                                          : Colors.black.withOpacity(
                                              0.3,
                                            ),
                                    ),
                                  ),
                                  child: DropdownButton<String>(
                                    value: title,
                                    iconSize: 36,
                                    isExpanded: true,
                                    underline: const SizedBox.shrink(),
                                    icon: const Icon(Icons.arrow_drop_down),
                                    items:
                                        titleType.map(buildMenuItem).toList(),
                                    onChanged: (v) => setState(
                                      () {
                                        title = v ?? "Mr";
                                      },
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: TSizes.spaceBtwItems,
                                ),

                                TextFormField(
                                  controller: firstName,
                                  // onChanged: (value) => setState(() {
                                  //   firstName.text = value;
                                  // }),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter FirstName';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: "First Name",
                                    prefixIcon: Icon(
                                      Iconsax.direct_right,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: TSizes.spaceBtwItems,
                                ),
                                TextFormField(
                                  controller: surname,
                                  // onChanged: (value) => setState(() {
                                  //   surname.text = value;
                                  // }),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter Surname';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: "Surname",
                                    prefixIcon: Icon(
                                      Iconsax.direct_right,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: TSizes.spaceBtwItems,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: !dark
                                          ? Colors.white
                                          : Colors.black.withOpacity(
                                              0.3,
                                            ),
                                    ),
                                  ),
                                  child: DropdownButton<String>(
                                    value: gender,
                                    iconSize: 36,
                                    isExpanded: true,
                                    underline: const SizedBox.shrink(),
                                    icon: const Icon(Icons.arrow_drop_down),
                                    items: genderTypes
                                        .map(buildMenuItemMap)
                                        .toList(),
                                    onChanged: (v) => setState(
                                      () {
                                        gender = v ?? "Male";
                                      },
                                    ),
                                  ),
                                ),
// existing code...
                                const SizedBox(
                                  height: TSizes.spaceBtwItems,
                                ),

                                const SizedBox(
                                  height: TSizes.spaceBtwItems,
                                ),
                                TextFormField(
                                  controller: phoneNumber,
                                  // onChanged: (value) => setState(() {
                                  //   phoneNumber.text = value;
                                  // }),
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    labelText: "Phone Number",
                                    prefixIcon: Icon(
                                      Iconsax.direct_right,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: TSizes.spaceBtwItems,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: !dark
                                          ? Colors.white
                                          : Colors.black.withOpacity(
                                              0.3,
                                            ),
                                    ),
                                  ),
                                  child: DropdownButton<String>(
                                    value: country,
                                    iconSize: 36,
                                    isExpanded: true,
                                    underline: const SizedBox.shrink(),
                                    icon: const Icon(Icons.arrow_drop_down),
                                    items:
                                        countries.map(buildMenuItem).toList(),
                                    onChanged: (v) => setState(
                                      () {
                                        country = v ?? "Male";
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: TSizes.spaceBtwItems,
                                ),

                                TextFormField(
                                  controller: profession,
                                  // onChanged: (value) => setState(() {
                                  //   profession.text = value;
                                  // }),
                                  decoration: const InputDecoration(
                                    labelText: "Profession",
                                    prefixIcon: Icon(
                                      Iconsax.direct_right,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: TSizes.spaceBtwItems,
                                ),

                                TextFormField(
                                  controller: institution,
                                  // onChanged: (value) => setState(() {
                                  //   institution.text = value;
                                  // }),
                                  decoration: const InputDecoration(
                                    labelText: "Company",
                                    prefixIcon: Icon(
                                      Iconsax.direct_right,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: TSizes.spaceBtwItems,
                                ),
                                TextFormField(
                                  controller: city,
                                  // onChanged: (value) => setState(() {
                                  //   city.text = value;
                                  // }),
                                  decoration: const InputDecoration(
                                    labelText: "City",
                                    prefixIcon: Icon(
                                      Iconsax.direct_right,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: TSizes.spaceBtwItems,
                                ),

                                TextFormField(
                                  controller: address,
                                  // onChanged: (value) => setState(() {
                                  //   address.text = value;
                                  // }),
                                  decoration: const InputDecoration(
                                    labelText: "Address",
                                    prefixIcon: Icon(
                                      Iconsax.direct_right,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: TSizes.spaceBtwItems,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: !dark
                                            ? Colors.white
                                            : Colors.black.withOpacity(
                                                0.3,
                                              ),
                                      )),
                                  child: DropdownButton<String>(
                                    value: selectedTertiary,
                                    iconSize: 36,
                                    isExpanded: true,
                                    underline: const SizedBox.shrink(),
                                    icon: const Icon(Icons.arrow_drop_down),
                                    hint: const Text(
                                        'Select your tertiary institution'),
                                    items: [
                                      'University Of Ghana (Legon)',
                                      'Kwame Nkrumah University of Science and Technology (KNUST)',
                                      'University of Energy and Natural Resources (UENR)',
                                      'University of Mines and Technology (UMaT)',
                                      'University for Development Studies (UDS)',
                                      'Radford University College',
                                    ].map((String institution) {
                                      return DropdownMenuItem<String>(
                                        value: institution,
                                        child: Text(institution),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedTertiary = newValue;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: TSizes.spaceBtwItems,
                                ),

                                TextFormField(
                                  expands: false,
                                  controller: dateGraduationController,
                                  onChanged: (value) => setState(() {
                                    dateGraduationController.text = value;
                                  }),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter Date';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: "Year Of Graduation",
                                    prefixIcon: Icon(
                                      Iconsax.calendar,
                                    ),
                                  ),
                                  readOnly: true,
                                  onTap: () => selectedDate(),
                                ),
                                const SizedBox(
                                  height: TSizes.spaceBtwItems,
                                ),

                                const SizedBox(
                                  height: TSizes.spaceBtwItems,
                                ),
                                //Login
                                BlocBuilder<SelectImageBloc, SelectImageState>(
                                  builder: (context, state) {
                                    return SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          print(
                                              'Simple  ${institution.text.trim()}');
                                          Navigator.pop(context);
                                          context.read<AuthBloc>().add(
                                                EventEditUserInfo(
                                                  userInfo: UserInfo(
                                                    debit:
                                                        widget.userInfo.debit,
                                                    city_: city.text.trim(),
                                                    firstName_:
                                                        firstName.text.trim(),
                                                    phone_:
                                                        phoneNumber.text.trim(),
                                                    surname_:
                                                        surname.text.trim(),
                                                    nameOfInstitution_:
                                                        institution.text.trim(),
                                                    address_:
                                                        address.text.trim(),
                                                    tertiary_:
                                                        selectedTertiary ?? "",
                                                    title_: title,
                                                    gender_: gender,
                                                    yearOfGraduation_:
                                                        dateGraduationController
                                                            .text
                                                            .trim(),
                                                    ownerUserId: widget
                                                        .userInfo.ownerUserId,
                                                    imageUrl_: state.url,
                                                    email_: email.text.trim(),
                                                    country_: country,
                                                    dateOfBirth_: widget
                                                        .userInfo.dateOfBirth_,
                                                    profession_:
                                                        profession.text.trim(),
                                                    userId_:
                                                        widget.userInfo.userId_,
                                                  ),
                                                ),
                                              );
                                        },
                                        child: const Text("Save"),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      )),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Future<void> selectedDate() async {
    DateTime? selected = await showDatePicker(
      context: context,
      firstDate: DateTime(1800),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );

    if (selected != null) {
      graduatedYear = selected;
      setState(() {
        selectDate = selected.toString();
        dateGraduationController.text = "${selected.toLocal()}".split(' ')[0];
      });
    }
  }

  DropdownMenuItem<String> buildMenuItem(String item) {
    return DropdownMenuItem(
      value: item,
      child: Text(item),
    );
  }

  DropdownMenuItem<String> buildMenuItemMap(Map<String, String> item) {
    return DropdownMenuItem(
      value: item["value"],
      child: Text(item["name"] ?? ""),
    );
  }
}
