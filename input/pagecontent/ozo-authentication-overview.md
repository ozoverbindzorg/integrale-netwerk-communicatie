The OZO network of trust can be built through a Verifiable Credential (VC) architecture where OZO is the issuer of membership credentials. OZO, and specifically OZO's did:web, is considered a Trusted Party (TP) by all members who join.

<img alt="Image" style="float: none; width:40%; display: block" src="Trust%201.png"/>

The membership architecture is as follows: The OZO nuts node issues a VC to the member's NUTS node. This saves him. At the time of communication, the member's NUTS node presents a VP based on the membership VC.

<img alt="Image" style="float: none; width:40%; display: block" src="Trust%202.png"/>

This model uses the following credential:
```yaml
Type: NutsOrganizationCredential
Issuer: did OZO
Subject: did Lid
```
