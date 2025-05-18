import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../../service/auth/auth_exceptions.dart';
import '../../service/auth/bloc/auth_bloc.dart';
import '../../service/auth/bloc/auth_event.dart';
import '../../service/auth/bloc/auth_state.dart';
import '../../service/select_image/bloc/select_image_bloc.dart';
import '../../service/select_image/bloc/select_image_event.dart';
import '../../service/select_image/bloc/select_image_state.dart';
import '../../utils/constants/size.dart';
import '../../utils/constants/text_string.dart';
import '../../utils/device/device_utility.dart';
import '../../utils/dialogs/error_dialog.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late TextEditingController email;
  late TextEditingController password;

  late TextEditingController city;
  late TextEditingController firstName;
  late TextEditingController profession;
  late TextEditingController qualification;
  late TextEditingController phoneNumber;
  late TextEditingController surname;
  late TextEditingController address;
  late TextEditingController institution;
  late TextEditingController tertiary;
  late TextEditingController dateGraduationController;
  late TextEditingController dateOfBirthController;

  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

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
  String value = "SMGhIG";
  String title = "Mr";
  String gender = "M";
  String selectDate = "";
  DateTime dateOfBirth = DateTime.now();
  String country = "Ghana";
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

  // Add this class to represent a Degree

  bool showSelectedComponents = false;

  @override
  void initState() {
    dateGraduationController = TextEditingController();
    dateOfBirthController = TextEditingController();
    email = TextEditingController();
    password = TextEditingController();
    city = TextEditingController();
    firstName = TextEditingController();
    profession = TextEditingController();
    qualification = TextEditingController();
    phoneNumber = TextEditingController();
    surname = TextEditingController();
    address = TextEditingController();
    institution = TextEditingController();
    tertiary = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    city.dispose();
    firstName.dispose();
    profession.dispose();
    qualification.dispose();
    phoneNumber.dispose();
    surname.dispose();
    address.dispose();
    institution.dispose();
    tertiary.dispose();
    dateGraduationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = TDeviceUtils.getMode(context);
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(context, "Weak Password");
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(context, "Email is already in use");
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, "Failed To Register");
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, "Invalid Email");
          }
        }
      },
      child: SafeArea(
        child: Scaffold(
          body: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      2 * TSizes.buttomHeight,
                ),
                child: Form(
                  key: _formKey,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 840,
                    ),
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
                                      if (state is SelectImageStateUploading) {
                                        return const CircularProgressIndicator();
                                      } else if (state
                                          is SelectImageStateInit) {
                                        return Stack(
                                          children: [
                                            CircleAvatar(
                                              radius: 64,
                                              backgroundImage:
                                                  CachedNetworkImageProvider(
                                                state.url ?? "",
                                              ),
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
                                      } else if (state
                                          is SelectImageStateUploaded) {
                                        return Stack(
                                          children: [
                                            CircleAvatar(
                                              radius: 64,
                                              backgroundImage:
                                                  CachedNetworkImageProvider(
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: !dark
                                        ? Colors.white
                                        : Colors.black.withOpacity(
                                            0.3,
                                          ),
                                    width: 1,
                                  ),
                                ),
                                child: DropdownButton<String>(
                                  value: title,
                                  iconSize: 36,
                                  isExpanded: true,
                                  underline: const SizedBox.shrink(),
                                  icon: const Icon(Icons.arrow_drop_down),
                                  items: titleType.map(buildMenuItem).toList(),
                                  onChanged: (v) => setState(
                                    () {
                                      title = v ?? "Mr.";
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: TSizes.spaceBtwItems,
                              ),

                              TextFormField(
                                controller: firstName,
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: !dark
                                        ? Colors.white
                                        : Colors.black.withOpacity(
                                            0.3,
                                          ),
                                    width: 1,
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
                                      gender = v ?? "M";
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: TSizes.spaceBtwItems,
                              ),
                              TextFormField(
                                controller: phoneNumber,
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
                              TextFormField(
                                controller: email,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter Email';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: TText.email,
                                  prefixIcon: Icon(
                                    Iconsax.direct_right,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: TSizes.spaceBtwItems,
                              ),
                              // Password
                              TextFormField(
                                controller: password,
                                obscureText: !_isPasswordVisible,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter Password';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: TText.password,
                                  prefixIcon: const Icon(
                                    Iconsax.password_check,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Iconsax.eye
                                          : Iconsax.eye_slash,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: TSizes.spaceBtwItems,
                              ),
                              TextFormField(
                                expands: false,
                                controller: dateOfBirthController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Date';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: "Date Of Birth",
                                  prefixIcon: Icon(
                                    Iconsax.calendar,
                                  ),
                                ),
                                readOnly: true,
                                onTap: () => selectedDateOfBirth(),
                              ),
                              const SizedBox(
                                height: TSizes.spaceBtwItems,
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: !dark
                                        ? Colors.white
                                        : Colors.black.withOpacity(
                                            0.3,
                                          ),
                                    width: 1,
                                  ),
                                ),
                                child: DropdownButton<String>(
                                  value: country,
                                  iconSize: 36,
                                  isExpanded: true,
                                  underline: const SizedBox.shrink(),
                                  icon: const Icon(Icons.arrow_drop_down),
                                  items: countries.map(buildMenuItem).toList(),
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
                                controller: city,
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
                                decoration: const InputDecoration(
                                  labelText: "Address",
                                  prefixIcon: Icon(
                                    Iconsax.direct_right,
                                  ),
                                ),
                              ),
                              const SizedBox(height: TSizes.spaceBtwItems),

                              TextFormField(
                                controller: qualification,
                                decoration: const InputDecoration(
                                  labelText: "Qualification",
                                  prefixIcon: Icon(
                                    Iconsax.direct_right,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: TSizes.spaceBtwItems,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final email = this.email.text;
                                    final password = this.password.text;
                                    // final id = await _userInfoService
                                    // .fetchAndUpdateMemberNumber();
                                    if (url.isNotEmpty) {
                                      if (context.mounted) {
                                        context.read<AuthBloc>().add(
                                              AuthEventRegister(
                                                email: email.trim(),
                                                password: password.trim(),
                                                firstName:
                                                    firstName.text.trim(),
                                                surname: surname.text.trim(),
                                                phoneNumber:
                                                    phoneNumber.text.trim(),
                                                gender: gender,
                                                dateOfBirth:
                                                    dateOfBirthController.text
                                                        .trim(),
                                                title: title,
                                                address: address.text.trim(),
                                                institution:
                                                    institution.text.trim(),
                                                city: city.text.trim(),
                                                country: country,
                                                qualification:
                                                    qualification.text.trim(),
                                                tertiary: tertiary.text.trim(),
                                                yearOfGraduation:
                                                    dateGraduationController
                                                        .text
                                                        .trim(),
                                                imageUrl: url,
                                                profession:
                                                    profession.text.trim(),
                                              ),
                                            );
                                      }
                                      // await Future.delayed(
                                      //     const Duration(seconds: 5));

                                      // await _userInfoService.createNewNote(
                                      //   user: UserInfo(
                                      //     debit: -(await _userInfoService
                                      //         .getFirstDebt(
                                      //             value.toLowerCase())),
                                      //     membership: value,
                                      //     ownerUserId: '$id',
                                      //     firstName_: firstName.text.trim(),
                                      //     surname_: surname.text.trim(),
                                      //     email_: email,
                                      //     nameOfInstitution_:
                                      //         institution.text.trim(),
                                      //     yearOfGraduation_:
                                      //         dateGraduationController.text
                                      //             .trim(),
                                      //     address_: address.text.trim(),
                                      //     phone_: phoneNumber.text.trim(),
                                      //     imageUrl_: url,
                                      //     gender_: gender,
                                      //     dateOfBirth_:
                                      //         dateOfBirthController.text.trim(),
                                      //     title_: title,
                                      //     councilApproved_: "Pending",

                                      //     zonalSector_: "",
                                      //     tertiary_: tertiary.text.trim(),
                                      //     approvedBy_: "",
                                      //     city_: city.text.trim(),
                                      //     endorser1_: "",
                                      //     profession_: profession.text.trim(),
                                      //     qualification_:
                                      //         qualification.text.trim(),
                                      //     endorser2_: "",
                                      //     userId_: '$id',
                                      //     country_: country,
                                      //   ),
                                      // );
                                    } else {
                                      // Show alert dialog if fields are not filled or image is not selected

                                      if (context.mounted) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  'Incomplete Information'),
                                              content: const Text(
                                                  'Please fill in all fields and select an image.'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Close the dialog
                                                  },
                                                  child: const Text(
                                                    'OK',
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    }
                                  },
                                  child: const Text(TText.createAccount),
                                ),
                              ),
                              const SizedBox(
                                height: TSizes.spaceBtwSections,
                              ),
                              //Login
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                    context.read<AuthBloc>().add(
                                          const AuthEventLogOut(),
                                        );
                                  },
                                  child: const Text(TText.signIn),
                                ),
                              ),
                              const SizedBox(
                                height: TSizes.spaceBtwSections,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> selectedDateOfBirth() async {
    DateTime? selected = await showDatePicker(
      context: context,
      firstDate: DateTime(1800),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );

    if (selected != null) {
      dateOfBirth = selected;
      setState(() {
        selectDate = selected.toString();

        dateOfBirthController.text =
            "${selected.month}/${selected.day}/${selected.year}";
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
