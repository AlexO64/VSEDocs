pragma solidity ^0.4.11;

// Ethereum Doc Check version 1!
//
// Written by Alexander Ovchinnikov
contract mortal {
    /* Define variable owner of the type address*/
    address owner;

    /* this function is executed at initialization and sets the owner of the contract */
    function mortal() { owner = msg.sender; }

    /* Function to recover the funds on the contract */
    function kill() { if (msg.sender == owner) suicide(owner); }
}

contract bcProofOfDocTier1  is mortal {
  
  event LogIdentity( uint );
  event LogHash( bytes32 );
 
  uint private identity = 0; 

  mapping( uint => bytes32 ) private docDictionary;
 
  // helper function to get a document's sha256
  function calculateHash( string document ) constant returns ( bytes32 ){
    return sha256( document );
  }
 
  // check correct hash by id an document
  function checkDocumentByIdAndDoc( uint idx, string document ) constant returns ( bool ){
    var savedHash = docDictionary[ idx ];
    return savedHash == calculateHash( document );
  }
 
  // helper function to return currentindex value
  function returnLastIndex( ) constant returns ( uint ){
    return identity;
  }
 
  // helper function to return currentindex value
  function returnLastHash( ) constant returns ( bytes32 ){
    if( identity > 0 ){
      return docDictionary[ identity ];
    }
    return sha256( "" );
  }
 
  // calculate and store the document return - Id
  function saveDocument( string document ) returns( uint ){
    identity++;
    LogIdentity( identity );
    var hash = calculateHash( document );
    docDictionary[ identity ] = hash;
    LogHash( hash );
    return identity;
  }
}
