class ResponseGetDemandesList {
  List<Demandes>? demandes;

  ResponseGetDemandesList({this.demandes});

  ResponseGetDemandesList.fromJson(Map<String, dynamic> json) {
    if (json['demandes'] != null) {
      demandes = <Demandes>[];
      json['demandes'].forEach((v) {
        demandes!.add(new Demandes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.demandes != null) {
      data['demandes'] = this.demandes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Demandes {
  String? id;
  String? code;
  String? ville;
  String? projet;
  String? typeDemande;
  String? adresseInstallation;
  String? intervenant;
  String? longitude;
  String? latitude;
  String? client;
  String? contactClient;
  String? equipements;
  String? offre;
  String? plan;
  String? loginInternet;
  String? loginSip;
  String? numPersMandatee;
  String? nomPerMandatee;
  String? equipementLivre;
  String? adresseMac;
  String? portabilite;
  String? sousTypeOpportunite;
  String? typeLogement;
  String? userId;
  String? consommationCable;
  String? plaqueId;
  String? snTel;
  String? speed;
  String? debit;
  String? snRouteur;
  String? dnsn;
  String? pPbiAvant;
  String? pPboAvant;
  String? pPbiApres;
  String? pPboApres;
  String? pEquipementInstalle;
  String? pTestSignal;
  String? pEtiquetageIndoor;
  String? pEtiquetageOutdoor;
  String? pPassageCable;
  String? pFicheInstalation;
  String? pSpeedTest;
  String? etatId;
  String? motifEtatId;
  String? subStatutId;
  String? motifSubstatutId;
  String? dateRdv;
  String? created;

  Demandes(
      {this.id,
        this.code,
        this.ville,
        this.projet,
        this.typeDemande,
        this.adresseInstallation,
        this.intervenant,
        this.longitude,
        this.latitude,
        this.client,
        this.contactClient,
        this.equipements,
        this.offre,
        this.plan,
        this.loginInternet,
        this.loginSip,
        this.numPersMandatee,
        this.nomPerMandatee,
        this.equipementLivre,
        this.adresseMac,
        this.portabilite,
        this.sousTypeOpportunite,
        this.typeLogement,
        this.userId,
        this.consommationCable,
        this.plaqueId,
        this.snTel,
        this.speed,
        this.debit,
        this.snRouteur,
        this.dnsn,
        this.pPbiAvant,
        this.pPboAvant,
        this.pPbiApres,
        this.pPboApres,
        this.pEquipementInstalle,
        this.pTestSignal,
        this.pEtiquetageIndoor,
        this.pEtiquetageOutdoor,
        this.pPassageCable,
        this.pFicheInstalation,
        this.pSpeedTest,
        this.etatId,
        this.motifEtatId,
        this.subStatutId,
        this.motifSubstatutId,
        this.dateRdv,
        this.created});

  Demandes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    ville = json['ville'];
    projet = json['projet'];
    typeDemande = json['type_demande'];
    adresseInstallation = json['adresse_installation'];
    intervenant = json['intervenant'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    client = json['client'];
    contactClient = json['contact_client'];
    equipements = json['equipements'];
    offre = json['offre'];
    plan = json['plan'];
    loginInternet = json['login_internet'];
    loginSip = json['login_sip'];
    numPersMandatee = json['num_pers_mandatee'];
    nomPerMandatee = json['nom_per_mandatee'];
    equipementLivre = json['equipement_livre'];
    adresseMac = json['adresse_mac'];
    portabilite = json['portabilite'];
    sousTypeOpportunite = json['sous_type_opportunite'];
    typeLogement = json['type_logement'];
    userId = json['user_id'];
    consommationCable = json['consommation_cable'];
    plaqueId = json['plaque_id'];
    snTel = json['sn_tel'];
    speed = json['speed'];
    debit = json['debit'];
    snRouteur = json['sn_routeur'];
    dnsn = json['dnsn'];
    pPbiAvant = json['p_pbi_avant'];
    pPboAvant = json['p_pbo_avant'];
    pPbiApres = json['p_pbi_apres'];
    pPboApres = json['p_pbo_apres'];
    pEquipementInstalle = json['p_equipement_installe'];
    pTestSignal = json['p_test_signal'];
    pEtiquetageIndoor = json['p_etiquetage_indoor'];
    pEtiquetageOutdoor = json['p_etiquetage_outdoor'];
    pPassageCable = json['p_passage_cable'];
    pFicheInstalation = json['p_fiche_instalation'];
    pSpeedTest = json['p_speed_test'];
    etatId = json['etat_id'];
    motifEtatId = json['motif_etat_id'];
    subStatutId = json['sub_statut_id'];
    motifSubstatutId = json['motif_substatut_id'];
    dateRdv = json['date_rdv'];
    created = json['created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['ville'] = this.ville;
    data['projet'] = this.projet;
    data['type_demande'] = this.typeDemande;
    data['adresse_installation'] = this.adresseInstallation;
    data['intervenant'] = this.intervenant;
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    data['client'] = this.client;
    data['contact_client'] = this.contactClient;
    data['equipements'] = this.equipements;
    data['offre'] = this.offre;
    data['plan'] = this.plan;
    data['login_internet'] = this.loginInternet;
    data['login_sip'] = this.loginSip;
    data['num_pers_mandatee'] = this.numPersMandatee;
    data['nom_per_mandatee'] = this.nomPerMandatee;
    data['equipement_livre'] = this.equipementLivre;
    data['adresse_mac'] = this.adresseMac;
    data['portabilite'] = this.portabilite;
    data['sous_type_opportunite'] = this.sousTypeOpportunite;
    data['type_logement'] = this.typeLogement;
    data['user_id'] = this.userId;
    data['consommation_cable'] = this.consommationCable;
    data['plaque_id'] = this.plaqueId;
    data['sn_tel'] = this.snTel;
    data['speed'] = this.speed;
    data['debit'] = this.debit;
    data['sn_routeur'] = this.snRouteur;
    data['dnsn'] = this.dnsn;
    data['p_pbi_avant'] = this.pPbiAvant;
    data['p_pbo_avant'] = this.pPboAvant;
    data['p_pbi_apres'] = this.pPbiApres;
    data['p_pbo_apres'] = this.pPboApres;
    data['p_equipement_installe'] = this.pEquipementInstalle;
    data['p_test_signal'] = this.pTestSignal;
    data['p_etiquetage_indoor'] = this.pEtiquetageIndoor;
    data['p_etiquetage_outdoor'] = this.pEtiquetageOutdoor;
    data['p_passage_cable'] = this.pPassageCable;
    data['p_fiche_instalation'] = this.pFicheInstalation;
    data['p_speed_test'] = this.pSpeedTest;
    data['etat_id'] = this.etatId;
    data['motif_etat_id'] = this.motifEtatId;
    data['sub_statut_id'] = this.subStatutId;
    data['motif_substatut_id'] = this.motifSubstatutId;
    data['date_rdv'] = this.dateRdv;
    data['created'] = this.created;
    return data;
  }
}