// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:ghig/service/user/user.dart';
// import 'package:ghig/utils/generics/get_arguments.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:ghig/utils/image_picker/image_picker.dart';
// import 'package:flutter/foundation.dart';
// import '../../service/auth/auth_exceptions.dart';
// import '../../service/auth/auth_service.dart';
// import '../../service/auth/bloc/auth_bloc.dart';
// import '../../service/auth/bloc/auth_state.dart';
// import '../../service/user/firebase_cloud_storage.dart';
// import '../../utils/constants/size.dart';
// import '../../utils/device/device_utility.dart';
// import '../../utils/dialogs/error_dialog.dart';
// import 'package:firebase_storage/firebase_storage.dart';

// class Register extends StatefulWidget {
//   const Register({super.key});

//   @override
//   State<Register> createState() => _RegisterState();
// }

// class _RegisterState extends State<Register> {
//   final _accountFormKey = GlobalKey<FormState>();
//   final _registrationFormKey = GlobalKey<FormState>();
//   final _academicsFormKey = GlobalKey<FormState>();
//   final _addressFormKey = GlobalKey<FormState>();

//   UserInfo? _userInfo;
//   late final FirebaseCloudStorage _userInfoService;

//   late final TextEditingController _firstName;
//   late final TextEditingController _surname;
//   late final TextEditingController _email;
//   late final TextEditingController _password;
//   late final TextEditingController _membershipId;
//   late final TextEditingController _nameOfInstitution;
//   late final TextEditingController _programmeOfStudy;
//   late final TextEditingController _address;
//   late final TextEditingController _cityOrTown;
//   late final TextEditingController _phone;

//   late final TextEditingController _interest;
//   late final TextEditingController _speciality;
//   late final TextEditingController _jobTitle;
//   late final TextEditingController _tertiary;
//   late final TextEditingController _proffssion;
//   late final TextEditingController _qualification;

//   Future<UserInfo> createOrCreateExistingNote({
//     required String address,
//     required String email,
//     required String firstName,
//     required String membershipId,
//     required String nameOfInstitution,
//     required String phone,
//     required String programmeOfStudy,
//     required String surname,
//     required String cityOrTown,
//   }) async {
//     final currentUser = AuthService.firebase().currentUser!;
//     final userId = currentUser.id;

//     final newNote = await _userInfoService.createNewNote(
//         user: UserInfo(
//             documentId: userId,
//             ownerUserId: userId,
//             firstName_: firstName,
//             surname_: surname,
//             email_: email,
//             isNewMember_: isNewMember == 1 ? false : true,
//             membershipType_: value,
//             membershipId_: "",
//             nameOfInstitution_: nameOfInstitution,
//             programmeOfStudy_: programmeOfStudy,
//             yearOfGraduation_: graduatedYear,
//             address_: address,
//             phone_: phone,
//             imageUrl_: _userImageUrl,
//             gender_: gender,
//             dateOfBirth_: dateOfBirth,
//             title_: title,
//             councilApproved_: "Pending",
//             interest_: interest_,
//             speciality_: speciality_,
//             jobTitle_: jobTitle_,
//             zonalSector_: "",
//             tertiary_: tertiary_,
//             approvedBy_: "",
//             city_: cityOrTown,
//             endorser1_: "",
//             profession_: profession_,
//             qualification_: qualification_,
//             endorser2_: "",
//             userId_: await _userInfoService.fetchAndUpdateMemberNumber())

//         // ownerUserId: userId,
//         // address: address,
//         // email: email,
//         // firstName: firstName,
//         // imageUrl: _userImageUrl,
//         // isNewMember: isNewMember == 1 ? false : true,
//         // membershipId: membershipId,
//         // membershipType: value,
//         // nameOfInstitution: nameOfInstitution,
//         // phone: phone,
//         // programmeOfStudy: programmeOfStudy,
//         // surname: surname,
//         // town: cityOrTown,
//         // yearOfGraduation: graduatedYear,
//         // country: selectedCountry
//         );

//     _userInfo = newNote;
//     return newNote;
//   }

//   @override
//   void initState() {
//     _userInfoService = FirebaseCloudStorage();

//     _email = TextEditingController();
//     _password = TextEditingController();
//     _firstName = TextEditingController();
//     _surname = TextEditingController();
//     _membershipId = TextEditingController();
//     _nameOfInstitution = TextEditingController();
//     _programmeOfStudy = TextEditingController();
//     _address = TextEditingController();
//     _cityOrTown = TextEditingController();
//     _phone = TextEditingController();
//     super.initState();
//   }

//   @override
//   void dispose() {
// // _deleteNoteIfTextIsEmpty();

//     _email.dispose();
//     _password.dispose();
//     _firstName.dispose();
//     _surname.dispose();
//     _membershipId.dispose();
//     _nameOfInstitution.dispose();
//     _programmeOfStudy.dispose();
//     _address.dispose();
//     _cityOrTown.dispose();
//     _phone.dispose();
//     super.dispose();
//   }

//   Uint8List? _image;
//   int currentStep = 0;
//   int isNewMember = 1;
//   final TextEditingController _dateController = TextEditingController();
//   List<String> membershipType = [
//     "Student",
//     "Associate/Graduate",
//     "Professional",
//     "Fellowship",
//   ];
//   List<String> titleType = [
//     "Mr.",
//     "Mrs.",
//     "Miss",
//   ];
//   List<String> genderTypes = [
//     "Male",
//     "Female",
//   ];
//   String value = "Student";
//   String title = "Mr.";
//   String gender = "Male";
//   String selectDate = "";
//   DateTime graduatedYear = DateTime.now();
//   DateTime dateOfBirth = DateTime.now();

//   String _userImageUrl = "";

//   // Add this variable to track if image is selected
//   bool _isImageSelected = false;

//   // Add this variable to hold the selected country
//   String selectedCountry = "Select Country";

//   // List of countries (you can expand this list as needed)
//   List<String> countries = [
//     "Select Country",
//     "Afghanistan",
//     "Albania",
//     "Algeria",
//     "Andorra",
//     "Angola",
//     "Antigua and Barbuda",
//     "Argentina",
//     "Armenia",
//     "Australia",
//     "Austria",
//     "Azerbaijan",
//     "Bahamas",
//     "Bahrain",
//     "Bangladesh",
//     "Barbados",
//     "Belarus",
//     "Belgium",
//     "Belize",
//     "Benin",
//     "Bhutan",
//     "Bolivia",
//     "Bosnia and Herzegovina",
//     "Botswana",
//     "Brazil",
//     "Brunei",
//     "Bulgaria",
//     "Burkina Faso",
//     "Burundi",
//     "Cabo Verde",
//     "Cambodia",
//     "Cameroon",
//     "Canada",
//     "Central African Republic",
//     "Chad",
//     "Chile",
//     "China",
//     "Colombia",
//     "Comoros",
//     "Congo, Democratic Republic of the",
//     "Congo, Republic of the",
//     "Costa Rica",
//     "Croatia",
//     "Cuba",
//     "Cyprus",
//     "Czech Republic",
//     "Denmark",
//     "Djibouti",
//     "Dominica",
//     "Dominican Republic",
//     "East Timor (Timor-Leste)",
//     "Ecuador",
//     "Egypt",
//     "El Salvador",
//     "Equatorial Guinea",
//     "Eritrea",
//     "Estonia",
//     "Eswatini",
//     "Ethiopia",
//     "Fiji",
//     "Finland",
//     "France",
//     "Gabon",
//     "Gambia",
//     "Georgia",
//     "Germany",
//     "Ghana",
//     "Greece",
//     "Grenada",
//     "Guatemala",
//     "Guinea",
//     "Guinea-Bissau",
//     "Guyana",
//     "Haiti",
//     "Honduras",
//     "Hungary",
//     "Iceland",
//     "India",
//     "Indonesia",
//     "Iran",
//     "Iraq",
//     "Ireland",
//     "Israel",
//     "Italy",
//     "Ivory Coast",
//     "Jamaica",
//     "Japan",
//     "Jordan",
//     "Kazakhstan",
//     "Kenya",
//     "Kiribati",
//     "Korea, North",
//     "Korea, South",
//     "Kosovo",
//     "Kuwait",
//     "Kyrgyzstan",
//     "Laos",
//     "Latvia",
//     "Lebanon",
//     "Lesotho",
//     "Liberia",
//     "Libya",
//     "Liechtenstein",
//     "Lithuania",
//     "Luxembourg",
//     "Madagascar",
//     "Malawi",
//     "Malaysia",
//     "Maldives",
//     "Mali",
//     "Malta",
//     "Marshall Islands",
//     "Mauritania",
//     "Mauritius",
//     "Mexico",
//     "Micronesia",
//     "Moldova",
//     "Monaco",
//     "Mongolia",
//     "Montenegro",
//     "Morocco",
//     "Mozambique",
//     "Myanmar",
//     "Namibia",
//     "Nauru",
//     "Nepal",
//     "Netherlands",
//     "New Zealand",
//     "Nicaragua",
//     "Niger",
//     "Nigeria",
//     "North Macedonia",
//     "Norway",
//     "Oman",
//     "Pakistan",
//     "Palau",
//     "Palestine",
//     "Panama",
//     "Papua New Guinea",
//     "Paraguay",
//     "Peru",
//     "Philippines",
//     "Poland",
//     "Portugal",
//     "Qatar",
//     "Romania",
//     "Russia",
//     "Rwanda",
//     "Saint Kitts and Nevis",
//     "Saint Lucia",
//     "Saint Vincent and the Grenadines",
//     "Samoa",
//     "San Marino",
//     "Sao Tome and Principe",
//     "Saudi Arabia",
//     "Senegal",
//     "Serbia",
//     "Seychelles",
//     "Sierra Leone",
//     "Singapore",
//     "Slovakia",
//     "Slovenia",
//     "Solomon Islands",
//     "Somalia",
//     "South Africa",
//     "Spain",
//     "Sri Lanka",
//     "Sudan",
//     "Sudan, South",
//     "Suriname",
//     "Sweden",
//     "Switzerland",
//     "Syria",
//     "Taiwan",
//     "Tajikistan",
//     "Tanzania",
//     "Thailand",
//     "Togo",
//     "Tonga",
//     "Trinidad and Tobago",
//     "Tunisia",
//     "Turkey",
//     "Turkmenistan",
//     "Tuvalu",
//     "Uganda",
//     "Ukraine",
//     "United Arab Emirates",
//     "United Kingdom",
//     "United States",
//     "Uruguay",
//     "Uzbekistan",
//     "Vanuatu",
//     "Vatican City (Holy See)",
//     "Venezuela",
//     "Vietnam",
//     "Yemen",
//     "Zambia",
//     "Zimbabwe",
//   ];

//   void _selectImage() async {
//     try {
//       Uint8List img = await pickImage(ImageSource.gallery);
//       if (img.isNotEmpty) {
//         setState(() {
//           _image = img;
//         });
//         // Generate unique file name using timestamp
//         String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}';

//         // Detect image format (you might want to add more sophisticated detection)
//         String contentType;
//         String extension;

//         // Simple check for PNG signature
//         if (img.length > 8 &&
//             img[0] == 0x89 &&
//             img[1] == 0x50 &&
//             img[2] == 0x4E &&
//             img[3] == 0x47) {
//           contentType = 'image/png';
//           extension = 'png';
//         } else {
//           contentType = 'image/jpeg';
//           extension = 'jpg';
//         }

//         fileName = '$fileName.$extension';

//         // Get reference to Firebase Storage
//         final storageRef =
//             FirebaseStorage.instance.ref().child('profile_images/$fileName');

//         // Upload image
//         final uploadTask = await storageRef.putData(
//           img,
//           SettableMetadata(contentType: contentType),
//         );

//         // Get download URL
//         final imageUrl = await uploadTask.ref.getDownloadURL();

//         setState(() {
//           _isImageSelected = true;
//           _userImageUrl = imageUrl;
//         });
//       }
//     } catch (e) {
//       await showErrorDialog(context, 'Failed to Select a Valid Image');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dark = TDeviceUtils.getMode(context);
//     return BlocListener<AuthBloc, AuthState>(
//       listener: (context, state) async {
//         if (state is AuthStateRegistering) {
//           if (state.exception is WeakPasswordAuthException) {
//             await showErrorDialog(context, "Weak Password");
//           } else if (state.exception is EmailAlreadyInUseAuthException) {
//             await showErrorDialog(context, "Email is already in use");
//           } else if (state.exception is GenericAuthException) {
//             await showErrorDialog(context, "Failed To Register");
//           } else if (state.exception is InvalidEmailAuthException) {
//             await showErrorDialog(context, "Invalid Email");
//           }
//         }
//       },
//       child: Scaffold(
//           appBar: AppBar(
//             centerTitle: true,
//             title: Text(
//               "Register",
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//           ),
//           body: Stepper(
//             type: StepperType.vertical,
//             steps: getSteps(
//               dark: dark,
//               firstName: _firstName,
//               surname: _surname,
//               address: _address,
//               cityOrTown: _cityOrTown,
//               email: _email,
//               membershipId: _membershipId,
//               nameOfInstitution: _nameOfInstitution,
//               password: _password,
//               phone: _phone,
//               programmeOfStudy: _programmeOfStudy,
//             ),
//             currentStep: currentStep,
//             onStepContinue: () async {
//               bool canContinue = false;

//               // Validate current step
//               switch (currentStep) {
//                 case 0:
//                   if (!_isImageSelected) {
//                     return;
//                   }
//                   canContinue =
//                       _accountFormKey.currentState?.validate() ?? false;
//                   break;
//                 case 1:
//                   canContinue = isNewMember == 2
//                       ? _registrationFormKey.currentState?.validate() ?? false
//                       : true;
//                   break;
//                 case 2:
//                   canContinue =
//                       _academicsFormKey.currentState?.validate() ?? false;
//                   break;
//                 case 3:
//                   canContinue =
//                       _addressFormKey.currentState?.validate() ?? false;
//                   break;
//               }

//               if (!canContinue) return;

//               final isLastStep = currentStep ==
//                   getSteps(
//                         dark: dark,
//                         firstName: _firstName,
//                         surname: _surname,
//                         address: _address,
//                         cityOrTown: _cityOrTown,
//                         email: _email,
//                         membershipId: _membershipId,
//                         nameOfInstitution: _nameOfInstitution,
//                         password: _password,
//                         phone: _phone,
//                         programmeOfStudy: _programmeOfStudy,
//                       ).length -
//                       1;

//               if (isLastStep) {
//                 final firstName = _firstName.text.trim();
//                 final surname = _surname.text.trim();
//                 final address = _address.text.trim();
//                 final cityOrTown = _cityOrTown.text.trim();
//                 final email = _email.text.trim();
//                 final membershipId = _membershipId.text.trim();
//                 final nameOfInstitution = _nameOfInstitution.text.trim();
//                 final password = _password.text.trim();
//                 final phone = _phone.text.trim();
//                 final programmeOfStudy = _meOfStudy.text.trim();

//                 context.read<AuthBloc>().add(
//                       AuthEventRegister(
//                         email: email,
//                         password: password,
//                       ),
//                     );
//                 await Future.delayed(Duration(seconds: 5));
//                 await createOrCreateExistingNote(
//                   firstName: firstName,
//                   surname: surname,
//                   address: address,
//                   cityOrTown: cityOrTown,
//                   membershipId: membershipId,
//                   nameOfInstitution: nameOfInstitution,
//                   email: email,
//                   phone: phone,
//                   programmeOfStudy: programmeOfStudy,
//                 );
//               } else {
//                 setState(() {
//                   currentStep += 1;
//                 });
//               }
//             },
//             onStepCancel: () {
//               currentStep == 0
//                   ? null
//                   : setState(() {
//                       currentStep -= 1;
//                     });
//             },
//           )),
//     );
//   }

//   List<Step> getSteps({
//     required bool dark,
//     required TextEditingController firstName,
//     required TextEditingController surname,
//     required TextEditingController email,
//     required TextEditingController password,
//     required TextEditingController membershipId,
//     required TextEditingController nameOfInstitution,
//     required TextEditingController programmeOfStudy,
//     required TextEditingController address,
//     required TextEditingController cityOrTown,
//     required TextEditingController phone,
//   }) =>
//       [
//         Step(
//           state: currentStep > 0 ? StepState.complete : StepState.indexed,
//           isActive: currentStep >= 0,
//           title: Text("Account"),
//           content: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(TSizes.defaultSpace),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Form(
//                     key: _accountFormKey,
//                     child: Column(
//                       children: [
//                         Stack(
//                           children: [
//                             _image != null
//                                 ? CircleAvatar(
//                                     radius: 64,
//                                     backgroundImage: MemoryImage(
//                                       _image!,
//                                     ),
//                                   )
//                                 : const CircleAvatar(
//                                     radius: 64,
//                                     backgroundImage: NetworkImage(
//                                         "https://cdn-icons-png.flaticon.com/512/9203/9203764.png"),
//                                   ),
//                             Positioned(
//                               bottom: 0,
//                               left: 80,
//                               child: IconButton(
//                                 onPressed: _selectImage,
//                                 icon: const Icon(
//                                   Icons.add_a_photo,
//                                   size: 40,
//                                 ),
//                               ),
//                             )
//                           ],
//                         ),
//                         if (!_isImageSelected)
//                           const Padding(
//                             padding: EdgeInsets.only(top: 8.0),
//                             child: Text(
//                               'Please select a profile image',
//                               style: TextStyle(color: Colors.red, fontSize: 12),
//                             ),
//                           ),
//                         const SizedBox(
//                           height: TSizes.spaceBtwItems,
//                         ),
//                         TextFormField(
//                           expands: false,
//                           controller: firstName,
//                           decoration: const InputDecoration(
//                             labelText: "First Name",
//                             prefixIcon: Icon(
//                               Iconsax.user,
//                             ),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter your first name';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(
//                           height: TSizes.spaceBtwItems,
//                         ),
//                         TextFormField(
//                           expands: false,
//                           controller: surname,
//                           decoration: const InputDecoration(
//                             labelText: "Surname",
//                             prefixIcon: Icon(
//                               Iconsax.user,
//                             ),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter your surname';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(
//                           height: TSizes.spaceBtwItems,
//                         ),
//                         TextFormField(
//                           expands: false,
//                           controller: email,
//                           enableSuggestions: false,
//                           autocorrect: false,
//                           keyboardType: TextInputType.emailAddress,
//                           decoration: const InputDecoration(
//                             labelText: "E-mail",
//                             prefixIcon: Icon(
//                               Iconsax.direct,
//                             ),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter a valid email';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(
//                           height: TSizes.spaceBtwItems,
//                         ),
//                         TextFormField(
//                           expands: false,
//                           obscureText: !_isPasswordVisible,
//                           enableSuggestions: false,
//                           autocorrect: false,
//                           controller: password,
//                           decoration: InputDecoration(
//                             labelText: "Password",
//                             prefixIcon: const Icon(
//                               Iconsax.password_check,
//                             ),
//                             suffixIcon: IconButton(
//                               onPressed: () {
//                                 setState(() {
//                                   _isPasswordVisible = !_isPasswordVisible;
//                                 });
//                               },
//                               icon: Icon(
//                                 _isPasswordVisible
//                                     ? Iconsax.eye
//                                     : Iconsax.eye_slash,
//                               ),
//                             ),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter a valid password';
//                             }
//                             return null;
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         Step(
//           state: currentStep > 1 ? StepState.complete : StepState.indexed,
//           isActive: currentStep >= 1,
//           title: Text("Registration"),
//           content: SingleChildScrollView(
//             child: Form(
//               key: _registrationFormKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Registration Type:"),
//                   ListTile(
//                     title: Text('New Member'),
//                     leading: Radio(
//                       value: 1,
//                       groupValue: isNewMember,
//                       onChanged: (int? value) {
//                         setState(() {
//                           isNewMember = value!;
//                         });
//                       },
//                     ),
//                   ),
//                   ListTile(
//                     title: Text('Existing Member'),
//                     leading: Radio(
//                       value: 2,
//                       groupValue: isNewMember,
//                       onChanged: (int? value) {
//                         setState(() {
//                           isNewMember = value!;
//                         });
//                       },
//                     ),
//                   ),
//                   const SizedBox(
//                     height: TSizes.spaceBtwItems,
//                   ),
//                   Text("Membership Type:"),
//                   SizedBox(
//                     height: TSizes.spaceBtwItems,
//                   ),
//                   if (isNewMember == 2)
//                     Padding(
//                       padding: const EdgeInsets.only(
//                         bottom: TSizes.spaceBtwItems,
//                       ),
//                       child: TextFormField(
//                         expands: false,
//                         controller: membershipId,
//                         decoration: const InputDecoration(
//                           labelText: "Membership ID",
//                           prefixIcon: Icon(
//                             Iconsax.card,
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter a valid membership ID';
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 5),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: !dark
//                             ? Colors.white
//                             : Colors.black.withOpacity(
//                                 0.3,
//                               ),
//                         width: 1,
//                       ),
//                     ),
//                     child: DropdownButton<String>(
//                       value: value,
//                       iconSize: 36,
//                       isExpanded: true,
//                       underline: const SizedBox.shrink(),
//                       icon: const Icon(Icons.arrow_drop_down),
//                       items: membershipType.map(buildMenuItem).toList(),
//                       onChanged: (v) => setState(
//                         () {
//                           value = v ?? "Membership Type";
//                         },
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ),
//         Step(
//           state: currentStep > 2 ? StepState.complete : StepState.indexed,
//           isActive: currentStep >= 2,
//           title: Text(
//             "Acadamics",
//           ),
//           content: SingleChildScrollView(
//             child: Form(
//               key: _academicsFormKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(
//                       bottom: TSizes.spaceBtwItems,
//                     ),
//                     child: TextFormField(
//                       expands: false,
//                       controller: nameOfInstitution,
//                       decoration: const InputDecoration(
//                         labelText: "Name of Institution",
//                         prefixIcon: Icon(
//                           Iconsax.house,
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter a valid institution name';
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(
//                       bottom: TSizes.spaceBtwItems,
//                     ),
//                     child: TextFormField(
//                       expands: false,
//                       controller: programmeOfStudy,
//                       decoration: const InputDecoration(
//                         labelText: "Programme of Study",
//                         prefixIcon: Icon(
//                           Iconsax.book,
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter a valid programme of study';
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(
//                       bottom: TSizes.spaceBtwItems,
//                     ),
//                     child: TextFormField(
//                         expands: false,
//                         controller: _dateController,
//                         decoration: const InputDecoration(
//                           labelText: "Year of Graduation",
//                           prefixIcon: Icon(
//                             Iconsax.calendar,
//                           ),
//                         ),
//                         readOnly: true,
//                         onTap: () => selectedDate()),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         Step(
//           state: currentStep > 3 ? StepState.complete : StepState.indexed,
//           isActive: currentStep >= 3,
//           title: Text("Address"),
//           content: SingleChildScrollView(
//             child: Form(
//               key: _addressFormKey,
//               child: Column(
//                 children: [
//                   TextFormField(
//                     expands: false,
//                     controller: address,
//                     decoration: const InputDecoration(
//                       labelText: "Address",
//                       prefixIcon: Icon(
//                         Iconsax.location,
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter a valid address';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(
//                     height: TSizes.spaceBtwItems,
//                   ),
//                   TextFormField(
//                     expands: false,
//                     controller: cityOrTown,
//                     decoration: const InputDecoration(
//                       labelText: "Town/City",
//                       prefixIcon: Icon(
//                         Iconsax.house,
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter a valid town or city';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(
//                     height: TSizes.spaceBtwItems,
//                   ),
//                   TextFormField(
//                     expands: false,
//                     controller: phone,
//                     decoration: const InputDecoration(
//                       labelText: "Phone",
//                       prefixIcon: Icon(
//                         Iconsax.call,
//                       ),
//                     ),
//                     keyboardType: TextInputType.phone,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter a valid phone number';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: TSizes.spaceBtwItems),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 5),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: !dark
//                             ? Colors.white
//                             : Colors.black.withOpacity(0.3),
//                         width: 1,
//                       ),
//                     ),
//                     child: DropdownButton<String>(
//                       value: selectedCountry,
//                       iconSize: 36,
//                       isExpanded: true,
//                       underline: const SizedBox.shrink(),
//                       icon: const Icon(Icons.arrow_drop_down),
//                       items: countries.map(buildMenuItem).toList(),
//                       onChanged: (v) => setState(
//                         () {
//                           selectedCountry = v ?? "Select Country";
//                         },
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         )
//       ];

//   DropdownMenuItem<String> buildMenuItem(String e) => DropdownMenuItem(
//         child: Text(e),
//         value: e,
//       );

//   Future<void> selectedDate() async {
//     DateTime? selected = await showDatePicker(
//       context: context,
//       firstDate: DateTime(1800),
//       lastDate: DateTime.now(),
//       initialDate: DateTime.now(),
//     );

//     if (selected != null) {
//       graduatedYear = selected;
//       setState(() {
//         selectDate = selected.toString();
//         _dateController.text = "${selected.toLocal()}".split(' ')[0];
//       });
//     }
//   }

//   Future<void> selectedDateOfBirth() async {
//     DateTime? selected = await showDatePicker(
//       context: context,
//       firstDate: DateTime(1800),
//       lastDate: DateTime.now(),
//       initialDate: DateTime.now(),
//     );

//     if (selected != null) {
//       dateOfBirth = selected;
//       setState(() {
//         selectDate = selected.toString();
//         _dateController.text = "${selected.toLocal()}".split(' ')[0];
//       });
//     }
//   }
// }
