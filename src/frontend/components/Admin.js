import { useState, useEffect } from 'react'
import { ethers } from "ethers"
import { Row, Col, Card, Button, Form, InputGroup } from 'react-bootstrap'
import Modal from 'react-bootstrap/Modal';
import dispenserIdle from './assets/Idle.gif'
import dispenserActivate from './assets/Activate.gif'
import logo from './assets/PorkersLogo.png'
import info from './assets/info_button01.png'

const fromWei = (num) => ethers.utils.formatEther(num)
const toWei = (num) => ethers.utils.parseEther(num.toString())

const Admin = ({ web3Handler, account, nft, token, items }) => {
    return (
        <div className="m-0 p-0 container-fluid">
            <p>Admin Page</p>
        </div>
    );
}
export default Admin