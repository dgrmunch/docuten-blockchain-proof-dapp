import React, { Component } from "react";
import ProofOfLifeProxyContract from "./contracts/ProofOfLifeProxy.json";
import getWeb3 from "./utils/getWeb3";
import { library } from '@fortawesome/fontawesome-svg-core'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faCheck, faHistory, faSearch, faCalendar, faCertificate, faStamp  } from '@fortawesome/free-solid-svg-icons'
import "./App.css";

library.add(faCheck)
library.add(faHistory)
library.add(faSearch)
library.add(faCalendar)
library.add(faCertificate);
library.add(faStamp);

class App extends Component {
  
  //State inicialization
  state = { myDocuments: '', 
            docHash: '', 
            details: '',
            ipfsHash: '',
            registryInfo: '', 
            web3: null, 
            accounts: null, 
            contract: null,
            shouldHideDetailsSection: true,
            shouldHideSuccessAlert: true,           
            shouldHideWarningAlert: true,        
            shouldHideErrorAlert: true,
            successfulResponse: '',
            auditRegistries: '',
            warningResponse: ''
          };
  
  //Event Handlers  
  handleDocHashChange = this.handleDocHashChange.bind(this);
  handleIpfsHashChange = this.handleIpfsHashChange.bind(this);
  handleRegistryInfoChange = this.handleRegistryInfoChange.bind(this);
  
  handleDocHashChange(event) {
    this.setState({docHash: event.target.value});
  }
  
  handleIpfsHashChange(event) {
    this.setState({ipfsHash: event.target.value});
  }
  
  handleRegistryInfoChange(event) {
    this.setState({registryInfo: event.target.value});
  }
  
  // Contract calls  
  
  // Function to certify documents on the blockchain with document hash and IFPS hash
  certifyDocument(e) {
    
    const { accounts, contract, docHash, ipfsHash } = this.state;

    // We display a notification explaining that we are waiting for the transaction to be mined
    this.setState({ 
      warningResponse : 'A signed transaction will be included in the next mined block. Waiting for the Ethereum Network... ',
      shouldHideSuccessAlert : true,
      shouldHideErrorAlert : true,
      shouldHideWarningAlert : false,
      shouldHideDetailsSection: true,   
      details: ''
    });
    
    contract.methods.certifyDocumentCreationWithIPFSHash(docHash, ipfsHash, this.getTimestamp()).send({ from: accounts[0] }).then(
       result => {
        this.setState({ successfulResponse : "The document with hash '"+docHash+"' has been certified 🤟", 
                        block: result.blockHash,
                        transaction: result.transactionHash,
                        shouldHideSuccessAlert : false,
                        shouldHideWarningAlert : true,
                        shouldHideErrorAlert : true,
                        shouldHideDetailsSection: true,   
                        details: ''
                      });
        
        //Refresh list of "my documents"
        this.initializeState();      
      }
    );
  }
  
  // Function allows a document owner to append audit registries to them
  async addRegistryToDocument(e) {
    
    const { accounts, contract, docHash, registryInfo } = this.state;
    
    // We display a notification explaining that we are waiting for the transaction to be mined
    this.setState({ 
      warningResponse : 'A signed transaction will be included in the next mined block. Waiting for the Ethereum Network... ',
      shouldHideSuccessAlert : true,
      shouldHideErrorAlert : true,
      shouldHideWarningAlert : false,
      shouldHideDetailsSection: true,   
      details: ''
    });
    
    //Retrieve document id from hash
    const docId = await contract.methods.getId(docHash).call();
    
    // Append a new audit registry to the document with the current timestamp and the registry info
    contract.methods.appendAuditRegistry(docId, registryInfo, this.getTimestamp()).send({ from: accounts[0]}).then(
       result => {
        this.setState({ successfulResponse : "A new audit registry has been appended to the document with hash '"+docHash+"' 🤟", 
                        block: result.blockHash,
                        transaction: result.transactionHash,
                        shouldHideSuccessAlert : false,
                        shouldHideDetailsSection: true,   
                        shouldHideWarningAlert : true,
                        shouldHideErrorAlert : true,
                        details: ''
                      });  
        
        //Refresh list of "my documents"
        this.initializeState();      
      }
    );
  }
  
  // Function to verify document state on the blockchain (by hash)
  async verifyHash(e){    
    const { contract, docHash } = this.state;
    const documentDetail = await contract.methods.getDocumentDetailsByHash(docHash).call();
    this.viewDetails(documentDetail);
  }

  // Function to display document details and audit registries, directly from the ethereum contract  
  async viewDetails (doc) {
    
    const { contract } = this.state;

    // If there is not any registry in the smart contract status asocitated with docHash
    // the returned owner will be '0x0000000000000000000000000000000000000000'
    // In that case we display an error message explaining that that document is not certified
    if(doc[3] === '0x0000000000000000000000000000000000000000'){
      
      this.setState({ 
        errorResponse : 'Sorry! There is not any document with the hash <b>'+doc[1]+'</b> certified with this dApp 😒 ',
        shouldHideSuccessAlert : true,
        shouldHideWarningAlert : true,
        shouldHideErrorAlert : false,
        shouldHideDetailsSection: true,   
        details: ''
      });
      
    // Otherwise we display the certified document details
    } else {
    
      // Update state of document details in html view
      this.setState({ shouldHideDetailsSection: false, //show details section
                      currentDocHash :  doc[1],                     
                      currentDocOwner :  doc[3],
                      shouldHideSuccessAlert : true,
                      shouldHideWarningAlert : true,
                      shouldHideErrorAlert : true
      }); 
      
      // Include link to IPFS resource if available
      if(doc[2] !== '' && doc[2] !== undefined){
        this.setState({ currentDocIpfsLink :  '<a href="https://gateway.ipfs.io/ipfs/'+ doc[2]+'">/ipfs/'+doc[2]+'</a>'  }); 
      } else {
        this.setState({ currentDocIpfsLink :  ''  }); 
      }   
      
      // Retrieve also audit registries
      const auditRegistriesNumber = await contract.methods.countAuditRegistriesByDocumentHash(doc[1]).call();
      var registries = [];
      for(var i = 0; i<auditRegistriesNumber; i++){
        const auditRegistry = await contract.methods.getAuditRegistryByDocumentHash(doc[1], i).call();
        registries[i] = auditRegistry;
      }
    
      this.setState({ auditRegistries:  registries.map((auditReg, i) => <div className="row" key={i}>
                                                                            <div className="col-sm"><textarea disabled="disabled" rows="2" cols="40">{auditReg[0]}</textarea></div>                                                
                                                                            <div className="col-sm"><FontAwesomeIcon icon="calendar" /> {auditReg[1]}</div>
                                                                            <div className="col-sm"><FontAwesomeIcon icon="history" /> {auditReg[2].toString()}</div>
                                                                        </div>)});
    } // end if-else
  }

  // Function to refresh global status based on contract information
  initializeState = async () => {
    const { accounts, contract } = this.state;
    
    //Retrieve documents by logged account address
    const response = await contract.methods.getDocumentsByOwner(accounts[0]).call();
    var documents = response.toString().split(',');
    
    //Retrieve each document details
    for(var i = 0; i<documents.length; i++){
      const documentDetail = await contract.methods.getDocumentDetailsById(documents[i]).call();
      documents[i] = documentDetail;
    }
    
    if(documents.length > 0 && documents[0][1] !== ''){   
      //Display list of documents (clicking on each button will display the details of each doc)   
      this.setState({ myDocuments:  documents.map((doc, i) =><tr key={i}><td><button className="btn btn-outline-secondary btn-sm"  onClick={() => {this.viewDetails(doc)}} type="submit">{doc[1]}</button> </td></tr>)});
    }

    this.setState({ shouldHideWarningAlert : true, shouldHideErrorAlert: true });
  };
  
  // Initial function for dApp to work
  componentDidMount = async () => {
    try {
      
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();

      // Get the contract instance.
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = ProofOfLifeProxyContract.networks[networkId];
      const instance = new web3.eth.Contract(
        ProofOfLifeProxyContract.abi,
        deployedNetwork && deployedNetwork.address,
      );

      console.log("dApp connected to "+networkId);
      console.log("Address: "+deployedNetwork.address);
      console.log("ABI: "+ProofOfLifeProxyContract.abi);
      
      // Set web3, accounts, and contract to the state, and then proceed with an
      // initialization based on the interaction with the contract's methods.
      this.setState({ web3, accounts, contract: instance }, this.initializeState);
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`
      );
      console.log(error);
    }
  };
  
  // Auxiliary functions
  
  // Function to get current timestamp
  getTimestamp(){
    var today = new Date();
    return this.getFormatedTimestamp(today);
  }
  
  // Function to get formated timestamp from unix date
  getFormatedTimestamp(date){
    var dd = date.getDate();
    var mm = date.getMonth()+1;
    var yyyy = date.getFullYear();

    if(dd<10) {
        dd = '0'+dd
    } 

    if(mm<10) {
        mm = '0'+mm
    } 

    return mm + '-' + dd + '-' + yyyy + ' ' + date.getHours() + ':'+date.getMinutes()+':'+date.getSeconds() ;
  }
  
  // Render function
  render() {
    
    if (!this.state.web3) {
      return (

      <div className="App">  
          
        <nav className="navbar navbar-expand-lg navbar-light bg-light">
          
          <a className="navbar-brand" href="#">
            <img src="https://app.docuten.com/customizations/images/logo/logo.png" width="200" alt=""/>Blockchain Certification dApp
          </a>
        </nav>

        <div className="container-fluid">
        <br></br>
        <div className="row">    
            <div className="col-sm"></div>              
            <div className="col-sm">
                <div className="card" >
                  <div className="card-body">
                    <h5 className="card-title">Ready to login with Ethereum?</h5><br></br>
                    <p className="card-text"> In order to read and write on Ethereum you need a dApp-enabled browser.</p>
                    <div className="container-fluid">
                    <div className="alert alert-warning" role="alert">
                     If you are not using a dApp enabled browser you can install the <a href="http://metamask.com" target="_blank">Metamask</a> plugin and login! 
                     </div></div>                    
                  </div>
                  <img class="card-img-top" src="https://dgrmunch.github.io/docuten-blockchain-proof-dapp/metamaskConnectorLogo.png" alt="Metamask not loaded yet"></img>
                  
                </div>
            </div>
            <div className="col-sm"></div>
        </div>
        </div>
       </div>
      );
    }
    return (
      
      <div className="App">  
          
        <nav className="navbar navbar-expand-lg navbar-light bg-light">
          
          <a className="navbar-brand" href="#">
            <img src="https://app.docuten.com/customizations/images/logo/logo.png" width="200" alt=""/>Blockchain Certification dApp
          </a>
         
          <button className="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
            <span className="navbar-toggler-icon"></span>
          </button>

          <div className="collapse navbar-collapse" id="navbarSupportedContent">
            <ul className="navbar-nav mr-auto">
              <li className="nav-item"></li>
              <li className="nav-item"></li>             
            </ul>
            
            <form className="form-inline my-2 my-lg-0">
              <span className="badge badge-info">Logged as <b>{this.state.accounts[0]}</b></span><br></br>
            </form>
          </div>
          
      </nav>
      
      <div className="container-fluid">
        <div className="row">
        
          <div className="col-2">
              <br></br>
              <h5>My Documents</h5>
              <table><tbody><tr><td></td></tr>{this.state.myDocuments}</tbody></table>
          </div>
        
          <div className="col-10">
                <br></br>
                <div className="container-fluid">
                   <div className={this.state.shouldHideSuccessAlert ? 'hidden' : ''}>
                      <div className="alert alert-success" role="alert">
                          {this.state.successfulResponse}
                          <br></br>🧐 Block: <b>{this.state.block}</b>
                          <br></br>🧙‍♂️ Tx: <b>{this.state.transaction}</b>
                          
                      </div>
                    </div>
                    
                    <div className={this.state.shouldHideWarningAlert ? 'hidden' : ''}>
                      <div className="alert alert-warning" role="alert">
                          {this.state.warningResponse}<br></br>
                          <img src="https://dgrmunch.github.io/docuten-blockchain-proof-dapp/ajax-loader.gif"></img>
                        </div>
                    </div>

                    <div className={this.state.shouldHideErrorAlert ? 'hidden' : ''}>
                      <div className="alert alert-danger" role="alert">
                        <span dangerouslySetInnerHTML={{__html: this.state.errorResponse}}/><br></br>
                      </div>
                    </div>
                 
                   <div className="container-fluid">
                      <div className="row">                  
                        <div className="col-sm">
                            <div className="card" >
                              <div className="card-body">
                                <h5 className="card-title"> <FontAwesomeIcon icon="check" /> Proof-of-Existence</h5>
                                <p className="card-text">It allows the owner of a document to certify its existence and inmutability in the blockchain.</p>
                                <div className="container-fluid">
                                  <input className="form-control" type="search" placeholder="Document Hash"  onChange={this.handleDocHashChange} />
                                </div><br></br>
                                <div className="container-fluid">
                                  <input className="form-control" type="search" placeholder="IPFS Hash (Optional)"  onChange={this.handleIpfsHashChange} />
                                </div><br></br>
                                <div className="container-fluid">
                                  <button className="btn btn-primary"  onClick={this.certifyDocument.bind(this)} type="submit">Certify document</button> 
                                </div>
                              </div>
                            </div>
                        </div>
                        <div className="col-sm">
                            <div className="card" >
                             <div className="card-body">
                                <h5 className="card-title"><FontAwesomeIcon icon="history" /> Proof-of-Life</h5>
                                <p className="card-text">It allows the owner of a document to append audit registries to a certified document.</p>
                                <div className="container-fluid">
                                  <input className="form-control" type="search" placeholder="Document Hash"  onChange={this.handleDocHashChange} />
                                </div><br></br>
                                <div className="container-fluid">
                                  <input className="form-control" type="search" placeholder="Registry info"  onChange={this.handleRegistryInfoChange} />
                                </div><br></br>
                                <div className="container-fluid">
                                  <button className="btn btn-outline-primary"  onClick={this.addRegistryToDocument.bind(this)} type="submit">Add registry to document</button> 
                                </div>
                              </div>
                            </div>
                        </div>
                        <div className="col-sm">
                          <div className="card" >
                             <div className="card-body">
                                <h5 className="card-title"><FontAwesomeIcon icon="search" /> Verify Document Hash</h5>
                                <p className="card-text">It allows everybody to verify the status of a document and audit its history.</p>
                                <div className="container-fluid">
                                  <input className="form-control" type="search" placeholder="Document Hash"  onChange={this.handleDocHashChange} />
                                </div><br></br>
                                <div className="container-fluid">
                                  <button className="btn btn-outline-success"  onClick={this.verifyHash.bind(this)} type="submit">Verify document</button> 
                                </div> 
                               </div>
                            </div>
                        </div>
                      </div>               
                              
                      <div className="row">
                        <div className="col-sm">
                            <br/>
                            <div className={this.state.shouldHideDetailsSection ? 'hidden' : ''}>
                              <div className="jumbotron">
                                <h3 className="display-5"><FontAwesomeIcon icon="stamp" /> {this.state.currentDocHash}</h3>
                                <h4><span className="badge badge-success"><FontAwesomeIcon icon="certificate" /> Certified Document</span></h4>
                                <br/><span className="badge badge-light">Owned by {this.state.currentDocOwner}</span>
                                <p className="lead"><span dangerouslySetInnerHTML={{__html: this.state.currentDocIpfsLink}}/></p>
                                <hr className="my-4"/>
                                <div className="container-fluid">
                                    <div className="row">
                                        <div className="col-sm"><b>Event Description</b></div>                                                
                                        <div className="col-sm"><b>System Timestamp</b></div>
                                        <div className="col-sm"><b>Block Timestamp</b></div>
                                    </div>
                                    <div className="row">
                                       <br/>
                                    </div>
                                    {this.state.auditRegistries}
                                </div>                               
                              </div>  
                            </div>                    
                      </div>    
                    </div>
                              
                              
                                
                    </div>  </div> 
                    </div>
                
          </div>
        </div>
      </div>
    );
  }
}

export default App;
