# This file is maintained automatically by "tofu init".
# Manual edits may be lost in future updates.

provider "registry.opentofu.org/bpg/proxmox" {
  version     = "0.66.3"
  constraints = ">= 0.66.3"
  hashes = [
    "h1:pvHmVDhXF7Yv45MxTiB0nY3NEkFkCh4AJ5nYU1jYoK8=",
    "zh:372c7e42af71ea4be52fd61a9b29caa8cff913c38c2e639d84797060f0e78f8a",
    "zh:45b15873f78b13051fa8eaf59bc1d480ad1feaba7074ea97fb3775787a9bdadb",
    "zh:50792893b1d7441e39433b10ad706a14468fb43326842b06e2bc95fb3c9801fb",
    "zh:591ad7b8d2d4f12d617201caf5bacddca69e68ba396e6ff60d9d1ca0ee59a6f5",
    "zh:8d63f1eaf8a1731abffed0ef1ce15423bd56faebb1819743884841f7f9ab4126",
    "zh:90400a0beb68c99e262f9a6bc93daf9dfaeefdb3af673c2a86c17853c73fa868",
    "zh:9c0ff725d5a0c2095144a6eeb8c98fb9a3dc5f36c80e526ad63b51ce4094973a",
    "zh:a099fea3db1a858fc8688bf9e711a2962ab83fbb94d6507a773239aba8985834",
    "zh:a2a4d184e923e5d2ad92ebc414cba87c82b3c38e4183a825fbac573f7f8f5076",
    "zh:be762328a2608a2bb0a0a265964af57efe403bb3b11aa0fc2863355855fc4b9f",
    "zh:c84c8e17dc739132f85c2041a2493f7caa1f08850c4ee427462c98552a114371",
    "zh:d3daa7e19371fbedc3f4ddab47feb099205c6141ebc2fa1236b36aad52173723",
    "zh:d64ad91e29a6291ababd9ca86b32e6a36f50b806ca1079e74005a7ca2d037a8b",
    "zh:dc7eb38a771762570523f01cf6ae8def5b5f8acd5e173ca06b48f4f8511b7227",
    "zh:f26e0763dbe6a6b2195c94b44696f2110f7f55433dc142839be16b9697fa5597",
  ]
}

provider "registry.opentofu.org/fluxcd/flux" {
  version     = "1.4.0"
  constraints = ">= 1.4.0"
  hashes = [
    "h1:4CJVSpzhpcVIkzwLTLviB4rw6OvprkD8hqPaN2sCEKI=",
    "zh:03f84a2b61760160a91abd369e2f641992bdb81a13aa1f1dd3e370f43c7b8e90",
    "zh:0a4d44f6e93f28124d1a8138a19e54d5dcc527de3e700946481b9af9ce61e843",
    "zh:193af19c01abc6aa1ef01ad016e5717c4275ed529fbaa3ce1f6a922ba24f17f1",
    "zh:1c4be3504c359f35b9ee60451cf6a9bc225df66920f555caca45d2b62f79c459",
    "zh:32ea8a44fdd065cd9dbbdafd5eba348729a7791ee2f47bdb280734a8a1762231",
    "zh:42dcf34cb072ece2370bb438020d7b098d9f0f4f22f7420c058c87cb1b67c02b",
    "zh:48625dc5df70b78a638e0df395d64fce35f1befcdd632449a40f963f4b11c68f",
    "zh:534fb73b113c9b5fc9f1714c3c0cdf2f9a0c46fa312b5ee75d9a3197efaf3800",
    "zh:8f47b4dd487a2f68ce56833f175777d02035e91bee6fa75f9eee25b6c90d9e56",
    "zh:b6a67c1643ecee042ffdae2975e5d2b19edf781d30110f6d373713f7e604959e",
    "zh:bc808070a11ff32c0323b92c61356685dc5ce9d0f27367aa864c5ba26ad4e512",
    "zh:ce3b32cc8ef094c19cd34f64985f5ea72c24a77ee20fa844e516b8ab0f3b2062",
    "zh:da1e4ef7ac3e0fbccd4f12dfe50a34e69a2e6d46d4f82bf1a9c3897936332630",
    "zh:f343d6ebb06e1ebdb04d8cb5ad1271134664f6be6f092ec8ca2b9d1502a0f69c",
  ]
}

provider "registry.opentofu.org/hashicorp/http" {
  version = "3.4.5"
  hashes = [
    "h1:IkHNZ09hqg1TtLrUqUHIqoKXbNJE69dk917niblQf3U=",
    "zh:055a4431d33bb89b9848193152433eaead7cc2e6746d3436a5922419de2112bf",
    "zh:0bfabafea9f5e36802fcfc5a800831ec1767d896af889abc610014d02b09bdc2",
    "zh:300b4983fe1b43bd0a7dac1f94b30b3814f11c824224dd83fb45a521c02cea60",
    "zh:68f6958314ca5dc0868be70e37ec123b99b8828aa49f27fd2fdd13df05d31ab1",
    "zh:c29f098a597250adc2a7d9f99acbce3c9e07d37f1c5cfded5df4309738cf613c",
    "zh:c33607397f9c9302c0cd797c8b7484c9c6cfa09c3489d4b55af17df20b204368",
    "zh:d519ca364a224110428b390ee06e963a3ec4dfdd1ac816c9f32e647567957cf5",
    "zh:e4a9c7c0ac31a0192362ef43449390cdf00d2cf6f13061ef730b177eaf00ac45",
    "zh:f25223c062f274d8f89bb96017e73586030a205bc91cdad266a9954d0def2a23",
    "zh:fd4dc824ebae2f3a66318df364bec83b88e9a52e7f66b00dafa29a796d9a94ab",
  ]
}

provider "registry.opentofu.org/hashicorp/kubernetes" {
  version     = "2.31.0"
  constraints = ">= 2.31.0, 2.31.0"
  hashes = [
    "h1:z2qlqn6WbrjbezwQo4vvlwAgVUGz59klzDU4rlYhYi8=",
    "zh:0dd25babf78a88a61dd329b8c18538a295ea63630f1b69575e7898c89307da39",
    "zh:3138753e4b2ce6e9ffa5d65d73e9236169ff077c10089c7dc71031a0a139ff6d",
    "zh:644f94692dc33de0bb1183c307ae373efbf4ef4cb92654ccc646a5716edf9593",
    "zh:6cc630e43193220b1599e3227286cc4e3ca195910e8c56b6bacb50c5b5176dbf",
    "zh:764173875e77aa482da4dca9fec5f77c455d028848edfc394aa7dac5dfed6afd",
    "zh:7b1d380362d50ffbb3697483036ae351b0571e93b33754255cde6968e62b839f",
    "zh:a1d93ca3d8d1ecdd3b69242d16ff21c91b34e2e98f02a3b2d02c908aeb45189b",
    "zh:b471d0ab56dbf19c95fba68d2ef127bdb353be96a2be4c4a3dcd4d0db4b4180a",
    "zh:d610f725ded4acd3d31a240472bb283aa5e657ed020395bdefea18d094b8c2bf",
    "zh:d7f3ddd636ad5af6049922f212feb24830b7158410819c32073bf81c359cd2fa",
  ]
}

provider "registry.opentofu.org/hashicorp/local" {
  version = "2.5.2"
  hashes = [
    "h1:6lS+5A/4WFAqY3/RHWFRBSiFVLPRjvLaUgxPQvjXLHU=",
    "zh:25b95b76ceaa62b5c95f6de2fa6e6242edbf51e7fc6c057b7f7101aa4081f64f",
    "zh:3c974fdf6b42ca6f93309cf50951f345bfc5726ec6013b8832bcd3be0eb3429e",
    "zh:5de843bf6d903f5cca97ce1061e2e06b6441985c68d013eabd738a9e4b828278",
    "zh:86beead37c7b4f149a54d2ae633c99ff92159c748acea93ff0f3603d6b4c9f4f",
    "zh:8e52e81d3dc50c3f79305d257da7fde7af634fed65e6ab5b8e214166784a720e",
    "zh:9882f444c087c69559873b2d72eec406a40ede21acb5ac334d6563bf3a2387df",
    "zh:a4484193d110da4a06c7bffc44cc6b61d3b5e881cd51df2a83fdda1a36ea25d2",
    "zh:a53342426d173e29d8ee3106cb68abecdf4be301a3f6589e4e8d42015befa7da",
    "zh:d25ef2aef6a9004363fc6db80305d30673fc1f7dd0b980d41d863b12dacd382a",
    "zh:fa2d522fb323e2121f65b79709fd596514b293d816a1d969af8f72d108888e4c",
  ]
}

provider "registry.opentofu.org/hashicorp/time" {
  version = "0.12.1"
  hashes = [
    "h1:PnOB6IAQJoYi/r3iUH7Hml2c2zFrIzHksQsrK3VPjSI=",
    "zh:50a9b67d5f5f42adbdb7712f67858aa64b5670070f6710751239b535fb48a4df",
    "zh:5a846fae035e363aed75b966d64a56f3489a38083e8407aaa656730437f53ed7",
    "zh:6767f1fc8a679b48eaa4cd114da0d8185fb3546375f3a0fb3728f10fa3dbc551",
    "zh:85d3da407c828bf057cbc0e86c75ef3d0f9f74a73c4ea1b4aef18e33f41092b1",
    "zh:9180721325139431112c638f5382a740ff219782f81d6346cdff5bccc418a43f",
    "zh:9ba9989f905a64db1409a9a57649549c89c7aedfb55ae399a7fa9411aafaadac",
    "zh:b3d9e7afb6a742e9be0541bc434b00d849fdfab0b4b859ceb0296c26c541af15",
    "zh:c87da712d718acd9dd03f544b020c320699cb29df197be4f74783e3c3d80fc17",
    "zh:cb1abe07638ef6d7b41d0e86dfb12d60a513aca3395a5da7191947f7459821dd",
    "zh:ecff2e823ef49eda03663fa8ee8bdc17d27cd419dbdacbf1719f38812dbf417e",
  ]
}

provider "registry.opentofu.org/siderolabs/talos" {
  version     = "0.6.1"
  constraints = ">= 0.6.0"
  hashes = [
    "h1:eFw5nEpptkVQ+SNXFEaYa8o++5Q3WVznDgrxJ78ROLA=",
    "zh:0fa82a384b25a58b65523e0ea4768fa1212b1f5cfc0c9379d31162454fedcc9d",
    "zh:14f377dd6c3786583e1e8e10d74c762fd7767f84ab048d02cd418920f42686e7",
    "zh:2bff386f61360f306e0c7cd8d4e67048b7e38bfcb974dd7f70b1f385477fa08d",
    "zh:3601a3e133867abacc5836392db329dc6dfe52116263e2931837c8dfdf5d0bde",
    "zh:54b47cfd80a939ccfdc4ebb693796e930be98e2ca1b3676c3fe61b114ca12621",
    "zh:5b7cde484b9534bf5238c0f50da704edd53658bc376df5ef5b27406e4c80ee92",
    "zh:5e844e071112293b4fced2ac9dd0fa2f744e78db18732dd989fd54783408b667",
    "zh:a5442065fdc1de0bd38f70418b843d82570fb05a66e0a47c1358d0d9dab4418f",
    "zh:b140dae2b6d0a09c2160841bf75fc7a654d7249b5b9f59db07df980ed950ffec",
    "zh:b3cbf898cab3ae26be1dc3ed24b43f3a91510e6a190f5442c08957aaf1b6537e",
    "zh:ba5eca495b37a2fd8647c138f1d50090fcaeb266508b87e7b8c931f0b6bdb735",
    "zh:c0202c98f555fd7ecdc1b75255c3438351a557534c4ee0e9b55d678c007f785f",
    "zh:d4bf2b894ecba7437906a450ecf136f2885b85108b3d49f8e1a046611535c841",
    "zh:d89a71c1a3e2ea9cb109e2cbea7fd202a9ede5f5f0cc263ef50cb7f70c249c8e",
    "zh:d98a6963b680db5a91ac51ede3be175fa9621070df2f3774197b34db0fc2e964",
  ]
}
