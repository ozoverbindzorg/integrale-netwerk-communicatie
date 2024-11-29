# Authentication

## Network of trust
The OZO network of trust can be built through a Verifyable Credential (VC) architecture where OZO is the issuer of membership credentials. OZO, and specifically OZO's did:web, is considered a Trusted Party (TP) by all members who join.

[<img src="Trust%201.png" width="50%"/>](Trust%201.png)

The membership architecture is as follows: The OZO nuts node issues a VC to the member's NUTS node. This saves him. At the time of communication, the member's NUTS node presents a VP based on the membership VC.

[<img src="Trust%202.png" width="50%"/>](Trust%202.png)

This model uses the following credential:
```yaml
Type: OZOMembershipCredential
Issuer: did OZO
Subject: did Lid
```

## Connecting users
Linking users with OZO can be done by issuing a credential (VC) to the NUTS node of the client application, issued by the OZO did:web, linked to the OZO user, and issued to the user's did:web in the client domain.

[<img src="Trust%203.png" width="50%"/>](Trust%203.png)

This model uses the following credential:

```yaml
Type: OZOUserCredential
Issuer: another user
Subject: did client user
```


## Explanation of NUTS architecture
### Issuance overview

[<img src="Trust%204.png" width="50%"/>](Trust%204.png)

{% include nuts_issuance_overview.svg %}

{% include nuts_issuance_detail.svg %}

### Access overview

[<img src="Trust%205.png" width="50%"/>](Trust%205.png)

{% include nuts_access_token.svg %}

## Authenticate to the API as RelatedPerson



