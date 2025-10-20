The network interaction describes how to establish and maintain care networks using FHIR resources. This involves creating person resources (Patient, Practitioner, RelatedPerson), organizing them into care teams, and managing both floating professional teams and patient-specific care teams.

### Roles
This IG distinguishes the following roles when establishing care networks:
* The **OZO platform**, the environment where practitioners manage care teams and patient networks.
* The **OZO FHIR Api** that processes CRUD actions on Patient, Practitioner, RelatedPerson, and CareTeam resources.
* The **OZO client**, an environment where caregivers participate in care networks and interact with care teams.

### Identifier Requirements
All resources must include two types of identifiers:
* An **email identifier** with system "email" for communication purposes
* An **origin identifier** with system "{ORIGIN}/Person", "{ORIGIN}/Professional", or "{ORIGIN}/Team" to distinguish which system created the resource (typically using database IDs)

### Creating the Care Network - Order of Operations

#### 1. Create Person Resources
Person resources must be created first as they form the foundation of care teams:

##### Patient Resource
The Patient resource represents the care recipient. See example: [Patient-Jan-de-Hoop](Patient-Jan-de-Hoop.html)

##### Practitioner Resources
Practitioners represent healthcare professionals. Examples include:
- [Practitioner-Marijke-van-der-Berg](Practitioner-Marijke-van-der-Berg.html) (POH)
- [Practitioner-Pieter-de-Vries](Practitioner-Pieter-de-Vries.html) (Huisarts)
- [Practitioner-Annemiek-Jansen](Practitioner-Annemiek-Jansen.html) (Verpleegkundige)
- [Practitioner-Johan-van-den-Berg](Practitioner-Johan-van-den-Berg.html) (Fysiotherapeut)

##### RelatedPerson Resources
RelatedPersons represent family members, friends, or informal caregivers. Examples include:
- [RelatedPerson-Maria-Groen-de-Wit](RelatedPerson-Maria-Groen-de-Wit.html) (Spouse)
- [RelatedPerson-Thomas-Groen](RelatedPerson-Thomas-Groen.html) (Son)
- [RelatedPerson-Jane-Groen](RelatedPerson-Jane-Groen.html) (Family member)
- [RelatedPerson-Willem-Bakker](RelatedPerson-Willem-Bakker.html) (Friend/Informal caregiver)

#### 2. Create Floating Care Teams (Optional)
Floating care teams represent organizational units or departments without specific patient assignment. See example: [CareTeam-Department-Thuiszorg](CareTeam-Department-Thuiszorg.html)

#### 3. Create Patient Care Teams
Patient-specific care teams include a subject (the patient) and can include practitioners, related persons, and even other care teams. See example: [CareTeam-Jan-de-Hoop](CareTeam-Jan-de-Hoop.html)

### Key Principles

1. **Resource Creation Order**: Always create in this sequence:
   - Patient, Practitioner, and RelatedPerson resources first
   - Floating/department CareTeam resources (if needed)
   - Patient-specific CareTeam resources last

2. **Identifier Strategy**: 
   - Use email identifiers for communication routing
   - Use origin-specific identifiers to track resource ownership and prevent duplicates
   - Origin identifiers typically include the creating system's name and the local database ID

3. **Care Team Types**:
   - **Floating teams**: No subject, represent organizational units
   - **Patient teams**: Include subject reference to the patient
   - Teams can be nested - a CareTeam can be a participant in another CareTeam

4. **Participant Roles**: Include appropriate SNOMED CT codes to identify the role of each participant within the care team

### Interaction Diagram
The diagram below displays the sequence of creating a care network with nested teams:
{::nomarkdown}
{% include fhir-network-interaction.svg %}
{:/}

