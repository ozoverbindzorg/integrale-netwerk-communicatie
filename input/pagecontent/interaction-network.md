The network interaction describes how to establish and maintain care networks using FHIR resources. This involves creating person resources (Patient, Practitioner, RelatedPerson), organizing them into care teams, and managing both floating professional teams and patient-specific care teams.

### Roles
This IG distinguishes the following roles when establishing care networks:
* The **OZO platform**, the environment where practitioners manage care teams and patient networks.
* The **OZO FHIR Api** that processes CRUD actions on Patient, Practitioner, RelatedPerson, and CareTeam resources.
* The **OZO client**, an environment where caregivers participate in care networks and interact with care teams.

### Identifier Requirements
All resources must include at least one identifier. The OZO platform uses identifiers under the `https://www.ozoverbindzorg.nl/namingsystem/` base. Recognized systems per resource type:

* **Patient**: BSN (`http://fhir.nl/fhir/NamingSystem/bsn`), email, OZO person identifiers
* **RelatedPerson**: email, OZO person and network-relation identifiers
* **Practitioner**: AssignedId (`https://www.ozoverbindzorg.nl/namingsystem/professional`), BIG, UZI, AGB
* **Organization**: AssignedId (`https://www.ozoverbindzorg.nl/namingsystem/organization`), URA, AGB
* **CareTeam**: OZO team identifiers, email

All profiles use open slicing — additional identifier systems are accepted.

### Creating the Care Network - Order of Operations

#### 1. Create Person Resources
Person resources must be created first as they form the foundation of care teams:

##### Patient Resource
The Patient resource represents the care recipient. See example: [Jan-de-Hoop](Patient-Jan-de-Hoop.html)

##### Practitioner Resources
Practitioners represent healthcare professionals. Examples include:
- [Marijke-van-der-Berg](Practitioner-Marijke-van-der-Berg.html) (POH)
- [Pieter-de-Vries](Practitioner-Pieter-de-Vries.html) (Huisarts)
- [Annemiek-Jansen](Practitioner-Annemiek-Jansen.html) (Verpleegkundige)
- [Johan-van-den-Berg](Practitioner-Johan-van-den-Berg.html) (Fysiotherapeut)

##### RelatedPerson Resources
RelatedPersons represent family members, friends, or informal caregivers. Examples include:
- [Maria-Groen-de-Wit](RelatedPerson-Maria-Groen-de-Wit.html) (Spouse)
- [Thomas-Groen](RelatedPerson-Thomas-Groen.html) (Son)
- [Jane-Groen](RelatedPerson-Jane-Groen.html) (Family member)
- [Willem-Bakker](RelatedPerson-Willem-Bakker.html) (Friend/Informal caregiver)

#### 2. Create Organizational Care Teams (Optional)
Organizational care teams use the [OZOOrganizationalCareTeam](StructureDefinition-ozo-organizational-careteam.html) profile and represent departments or organizational units without specific patient assignment. They have no `subject`, require a `managingOrganization`, and only allow `Practitioner` participants. See example: [Department-Thuiszorg](CareTeam-Department-Thuiszorg.html)

#### 3. Create Patient Care Teams
Patient-specific care teams use the [OZOCareTeam](StructureDefinition-ozo-careteam.html) profile and include a subject (the patient). They can include practitioners, related persons, and even organizational care teams as nested participants. See example: [Netwerk-Jan-de-Hoop](CareTeam-Netwerk-Jan-de-Hoop.html)

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
   - **Organizational teams** ([OZOOrganizationalCareTeam](StructureDefinition-ozo-organizational-careteam.html)): No subject, represent organizational units (departments, shared inboxes). Only practitioners as members.
   - **Patient teams** ([OZOCareTeam](StructureDefinition-ozo-careteam.html)): Include subject reference to the patient. Practitioners, related persons, and organizational teams as members.
   - Teams can be nested — an organizational CareTeam can be a participant in a patient CareTeam

4. **Participant Roles**: Include appropriate SNOMED CT codes to identify the role of each participant within the care team

### Interaction Diagram
The diagram below displays the sequence of creating a care network with nested teams:
{::nomarkdown}
{% include fhir-network-interaction.svg %}
{:/}

