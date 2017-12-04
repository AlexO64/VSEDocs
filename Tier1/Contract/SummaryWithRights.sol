pragma solidity ^0.4.19;

contract Registrar {
    // owner of contract
    address public owner;
    
    /*
    * Declaration users part of contract
    */
    
    struct Registrant {
        address addr;
        bool active;
    }


    mapping(bytes32 => Registrant) public registrants;
    
    /*
    * Created event, gets triggered when a new registrant gets created
    * event
    * @param registrar - The registrar address.
    * @param orgId - The organization of the registrant.
    * @param registrant - The registrant address.
    */
    event CreatedRegistrant(address owner, string indexed orgId, address registrant);

    /*
    * Updated event, gets triggered when a new registrant id Updated
    * event
    * @param registrant - The registrant address.
    * @param registrar - The registrar address.
    * @param orgId - The data of the registrant.
    */
    event UpdatedRegistrant( address owner, string indexed orgId, address registrant );


    /*
    * Declaration of summary part of contract
    */
    
    struct Registry{
        string summary;
        bool active;
    }
    
    mapping( bytes32 => mapping( bytes32 => Registry )) public regEntry;
    
    /*
    * Create Summary event, gets triggered when a summary is Created
    * @param registrant - The registrant address.
    * @param schema - The schema of summary
    * @param orgId - The organization of the summary.
    * @param summary - The registrant address.
    */
    event CreatedSummary( address registrant, string indexed schema, string indexed orgId, string summary);

    /*
    * Updated Summary event, gets triggered when a summary is Updated
    * @param registrant - The registrant address.
    * @param schema - The schema of summary
    * @param orgId - The organization of the summary.
    * @param summary - The registrant address.
    */
    event UpdatedSummary(address registrant, string indexed schema, string indexed orgId, string summary);

    /*
    * Error event.
    * event
    * @param code - The error code.
    * 1: Permission denied.
    * 2: Duplicate Registrant address or Summary.
    * 3: No such Registrant or Summary.
    */
    event Error(uint code);

    /*
    * Function can't have ether.
    * modifier
    */
    
    modifier noEther() {
        require( msg.value == 0 );
        _;
    }   

    modifier isRegistrar() {
      if( msg.sender != owner ){
        Error(1);
        return;
      }
      else {
        _;
      }
    }

    /*
    * Construct registry with and starting registrants lenght of one, and registrar as msg.sender
    * constructor
    */
    function Registrar() public {
        owner = msg.sender;
    }

    /*
    * Add a registrant, only registrar allowed
    * public_function
    * @param _registrant - The registrant address.
    * @param _data - The registrant data string.
    */
    function addRegistrant(address _orgEditor, string _orgId ) public  isRegistrar noEther returns (bool) {
        if( registrants[ sha256( _orgId )].active ){
            Error(2); // Duplicate registrant for this organization
            return false;
        }
        registrants[ sha256( _orgId )] = Registrant( _orgEditor, true );
        CreatedRegistrant( msg.sender, _orgId, _orgEditor );
        return true;
    }

    /*
    * Edit a registrant, only registrar allowed
    * public_function
    * @param _registrant - The registrant address.
    * @param _orgId - The registrant organization string.
    */
    function editRegistrant(address _orgEditor, string  _orgId ) public isRegistrar noEther returns (bool) {
        if( !registrants[ sha256( _orgId ) ].active ){
            Error(3); // No such registrant
            return false;
        }
        Registrant storage item = registrants[ sha256( _orgId ) ];
        item.addr = _orgEditor;
        UpdatedRegistrant( msg.sender, _orgId, _orgEditor );
        return true;
    }

    /*
    * Set new registrar address, only registrar allowed
    * public_function
    * @param _registrar - The new registrar address.
    */
    function setNextRegistrar( address _registrar ) public isRegistrar noEther returns (bool) {
        owner = _registrar;
        return true;
    }

    /*
    * Get if a regsitrant is active or not.
    * constant_function
    * @param _registrant - The registrant address.
    */
    function isActiveRegistrant( address _registrar, string _orgId ) public constant returns ( bool  ) {
        if( _registrar == owner || _registrar == registrants[ sha256( _orgId ) ].addr ) {
            return true;
        } 
        return false;
    }

    /*
    * Get all the registrants.
    * constant_function
    */
    function getRegistrant( string _orgId ) public constant returns ( address ) {
        return registrants[ sha256( _orgId ) ].addr;
    }


    /*
    * Add a summary, only registrar or specific registrant is allowed
    * public_function
    * @param schema - The schema name.
    * @param orgId - organization name string.
    * @param summary - summary value string.
    */
    function addSummary( string _schema, string _orgId, string _summary ) public  noEther returns (bool) {
        if( !isActiveRegistrant( msg.sender, _orgId ) ){
            Error( 1 ); // Access denied
            return false;
        }
        if( regEntry[ sha256( _schema ) ][ sha256( _orgId ) ].active ){
            Error( 2 ); // Registry already exists
            return false;
        }
        regEntry[ sha256( _schema ) ][ sha256( _orgId ) ] = Registry( _summary, true );
        CreatedSummary( msg.sender, _schema, _orgId, _summary );
        return true;
    }

    /*
    * Edit a summary, only registrar allowed
    * public_function
    * @param _registrant - The registrant address.
    * @param _orgId - The registrant organization string.
    */
    
    function editSummary( string _schema, string _orgId, string _summary ) public noEther returns (bool) {
        if( !isActiveRegistrant( msg.sender, _orgId ) ){
            Error( 1 ); // Access denied
            return false;
        }
        
        Registry storage registryEntry = regEntry[ sha256( _schema ) ][ sha256( _orgId ) ];
        if( !registryEntry.active ){
            Error( 3 ); // No such entry 
            return false;
        }
        registryEntry.summary = _summary;
        UpdatedSummary( msg.sender, _schema, _orgId, _summary );
        return true;
    }
 
    function getSummary( string _schema, string _orgId ) public constant noEther returns (string){
        return regEntry[ sha256( _schema ) ][ sha256( _orgId ) ].summary;
    }
    
    /*
    * Function to reject value sends to the contract.
    * fallback_function
    */
    function () public noEther {}
}
