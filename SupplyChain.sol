// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract SupplyChain {
    //All Component Structs
    struct BuyerDetails {
        string name;
        uint locationPinCode;
        string locationName;
    }

    struct SellerDetails {
        string name;
        uint locationPinCode;
        string locationName;
        uint numberOfProducts;
    }

    struct DiliveryOfficial {
        uint locationPinCode;
        string locationName;
        uint employeeID;
        string companyName;
    }

    struct DiliveryBoy {
        uint locationPinCode;
        string locationName;
        uint employeeID;
        string companyName;
    }

    struct Product {
        string name;
        string description;
        address payable seller;
        uint productID;
        uint price;
        address buyer;
        address payable diliveryGuy;
        string diliveryCompany;
        uint diliveryPrice;
        address currentDiliveryPriceAdder;
        ProductStatus status;
    }

    //Product status
    enum ProductStatus {
        Registered,
        Baught,
        DiliveryPriceAdded,
        PickedUpForDilivery,
        OutForDilivery,
        DiliveryConfirmByDiliveryGuy,
        Dilivered
    }

    //The Product array
    Product[] public products;
    uint public productID = 1;

    //All Data stored in mappings
    mapping(address => DiliveryOfficial) public diliveryOfficials;
    mapping(address => DiliveryBoy) public diliveryBoys;
    mapping(address => BuyerDetails) public buyers;
    mapping(address => SellerDetails) public sellers;

    //Modifiers
    modifier onlyDiliveryOfficial() {
        require(diliveryOfficials[msg.sender].employeeID != 0, "Access denied");
        _;
    }

    modifier onlyDiliveryBoy() {
        require(diliveryBoys[msg.sender].employeeID != 0, "Access denied");
        _;
    }

    modifier onlySellers() {
        require(sellers[msg.sender].locationPinCode != 0, "Access denied");
        _;
    }

    modifier onlyBuyer() {
        require(buyers[msg.sender].locationPinCode != 0, "Access denied");
        _;
    }

    modifier statusRegistered(uint _productID) {
        require(
            products[_productID - 1].status == ProductStatus.Registered,
            "This product is unavailable"
        );
        _;
    }

    modifier statusBaught(uint _productID) {
        require(
            products[_productID - 1].status == ProductStatus.Baught,
            "This product is unavailable"
        );
        _;
    }

    modifier diliveryPriceAdded(uint _productID) {
        require(
            products[_productID - 1].status == ProductStatus.DiliveryPriceAdded,
            "No comapany have offered for dilivery"
        );
        _;
    }

    modifier statusNotDilivered(uint _productID) {
        require(
            products[_productID - 1].status != ProductStatus.Dilivered,
            "This product is unavailable"
        );
        _;
    }

    //Functions
    function signUpForBuyer(
        string memory _name,
        uint _locationPinCode,
        string memory _locationName
    ) public {
        require(_locationPinCode != 0, "Enter valid location");
        BuyerDetails memory BD;
        BD.name = _name;
        BD.locationPinCode = _locationPinCode;
        BD.locationName = _locationName;
        buyers[msg.sender] = BD;
    }

    function signUpForSeller(
        string memory _name,
        uint _locationPinCode,
        string memory _locationName
    ) public {
        require(_locationPinCode != 0, "Enter valid location");
        SellerDetails memory SD;
        SD.name = _name;
        SD.locationPinCode = _locationPinCode;
        SD.locationName = _locationName;
        sellers[msg.sender] = SD;
    }

    function signUpForDeliveryOfficial(
        string memory _locationName,
        uint _locationPinCode,
        string memory _companyName,
        uint _employeeID
    ) public {
        require(_locationPinCode != 0, "Enter valid location");
        DiliveryOfficial memory DO;
        DO.locationPinCode = _locationPinCode;
        DO.locationName = _locationName;
        DO.companyName = _companyName;
        DO.employeeID = _employeeID;
        diliveryOfficials[msg.sender] = DO;
    }

    function addDiliveryBoy(
        address _address,
        uint _employeeID,
        uint _locationPinCode
    ) public onlyDiliveryOfficial {
        require(_employeeID != 0, "Enter the value ");
        DiliveryBoy memory DB;
        DB.locationPinCode = diliveryOfficials[msg.sender].locationPinCode;
        DB.locationName = diliveryOfficials[msg.sender].locationName;
        DB.companyName = diliveryOfficials[msg.sender].companyName;
        DB.employeeID = _employeeID;
        DB.locationPinCode = _locationPinCode;
        diliveryBoys[_address] = DB;
    }

    function regProduct(
        string memory _name,
        string memory _desc,
        uint _price
    ) public onlySellers {
        require(_price > 0, "Price of a product cannot be zero");
        Product memory tempProduct;
        tempProduct.name = _name;
        tempProduct.description = _desc;
        tempProduct.price = _price * 10 ** 18;
        tempProduct.seller = payable(msg.sender);
        tempProduct.productID = productID;
        tempProduct.diliveryPrice = 1;
        tempProduct.status = ProductStatus.Registered;
        products.push(tempProduct);
        productID++;
    }

    function addDiliveryPrice(
        uint _productID,
        uint _dPrice
    )
        public
        onlyDiliveryOfficial
        statusRegistered(_productID)
        statusNotDilivered(_productID)
    {
        require(
            diliveryOfficials[msg.sender].locationPinCode ==
                sellers[products[_productID - 1].seller].locationPinCode,
            "You cannot get this dilivery"
        );
        require(
            products[_productID - 1].diliveryPrice > _dPrice,
            "Somebady is willing to diliver this at lower price than you"
        );
        products[_productID - 1].diliveryPrice = _dPrice * 10 ** 18;
        products[_productID - 1].currentDiliveryPriceAdder = msg.sender;
    }

    function buy(
        uint _productID
    )
        public
        payable
        onlyBuyer
        statusRegistered(_productID)
        statusNotDilivered(_productID)
        diliveryPriceAdded(_productID)
    {
        require(
            products[_productID - 1].seller != msg.sender,
            "Seller is not allowed to buy their own product"
        );
        require(
            products[_productID - 1].price +
                products[_productID - 1].diliveryPrice ==
                msg.value,
            "Enter Exact amount"
        );
        products[_productID - 1].buyer = msg.sender;
        products[_productID - 1].status = ProductStatus.Baught;
    }

    function peakUpDilivery(
        uint _productID
    ) public onlyDiliveryOfficial statusBaught(_productID) {
        require(
            msg.sender == products[_productID - 1].currentDiliveryPriceAdder
        );
        require(
            diliveryOfficials[msg.sender].locationPinCode ==
                sellers[products[_productID - 1].seller].locationPinCode,
            "You cannot get this dilivery"
        );
        products[_productID - 1].diliveryCompany = diliveryOfficials[msg.sender]
            .companyName;
        products[_productID - 1].diliveryGuy == msg.sender;
        products[_productID - 1].status = ProductStatus.PickedUpForDilivery;
    }

    function getDilivery(uint _productID) public onlyDiliveryBoy {
        require(
            diliveryBoys[msg.sender].locationPinCode ==
                buyers[products[_productID - 1].buyer].locationPinCode,
            "You cannot diliver this"
        );
        require(
            products[_productID - 1].status ==
                ProductStatus.PickedUpForDilivery,
            "Product is not in the chain"
        );
        products[_productID - 1].status = ProductStatus.OutForDilivery;
    }

    function diliveredByDiliveryBoy(uint _productID) public onlyDiliveryBoy {
        require(
            products[_productID - 1].diliveryGuy == msg.sender,
            "Access denied"
        );
        require(
            products[_productID - 1].status == ProductStatus.OutForDilivery,
            "Access denied"
        );
        products[_productID - 1].status = ProductStatus
            .DiliveryConfirmByDiliveryGuy;
    }

    function confirmDilivery(uint _productID) public onlyBuyer {
        require(products[_productID - 1].buyer == msg.sender, "Access denied");
        require(
            products[_productID - 1].status ==
                ProductStatus.DiliveryConfirmByDiliveryGuy,
            "Access denied"
        );
        products[_productID - 1].status = ProductStatus.Dilivered;
        (products[_productID - 1].seller).transfer(
            products[_productID - 1].price
        );
        (products[_productID - 1].diliveryGuy).transfer(
            products[_productID - 1].diliveryPrice
        );
    }
}
