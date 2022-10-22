import {
    Link
} from "react-router-dom";

import { Navbar, Nav, Button, Container } from 'react-bootstrap'
import logo from './assets/PorkersLogo.png'
import info from './assets/info_button01.png'

const Navigation = ({ web3Handler, account }) => {

    const infoPopup = () => {
        console.log("infoPopup")
    }

    return (
        <Navbar expand="lg" variant="dark">
            <Container>
                <Navbar.Brand>
                    <img src={logo} className="" alt="" />
                </Navbar.Brand>
                <Navbar.Toggle aria-controls="responsive-navbar-nav" />
                <Navbar.Collapse id="responsive-navbar-nav">
                    <Nav className="me-auto">
                    </Nav>
                    <Nav>
                        {account ? (
                            <div class="roseButton mx-3"><p>{account.slice(0, 6)}...</p></div>
                        ) : (
                            <div class="roseButton mx-3" onClick={web3Handler}><p>CONNECT</p></div>
                        )}
                    </Nav>
                    <Nav>
                        <img class="mx-3" src={info} onClick={infoPopup} />
                    </Nav>
                </Navbar.Collapse>
            </Container>
        </Navbar>
    )

}

export default Navigation;