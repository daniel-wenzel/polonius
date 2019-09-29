import express from 'express';
import Address from '../../../db/address'
import { getAddressesByName } from '../../../db/sql/getAddressesByName'
import { Request, Response } from 'express';
import { INode, IGraph, ITransfer } from '../../../db/types';


const route = express.Router()

route.get('/:address', async (req: Request, res: Response) => {
    try {

        if (req.params.address.startsWith('0x')) {
            const address = new Address(req.params.address.toLowerCase())
            const node = await address.getBasicStats()
            const transfers = await address.getTransfers()
            res.render('index', { transfers, address: req.params.address, node })
        }
        else {
            const addresses = getAddressesByName(req.params.address)
            const address = new Address(addresses[0])
            const node = await address.getBasicStats()
            const transfers = await address.getTransfers()
            res.render('index', { transfers, address: req.params.address, node })
        }
    }
    catch (e) {
        console.error(e)
        res.status(500).send("internal server error")
    }
})

route.get('/:address/neighbourhoodGraph', async (req: Request, res: Response) => {
    try {


        if (req.params.address.startsWith('0x')) {
            const address = new Address(req.params.address.toLowerCase())
            const graph = await address.getSubgraph()
            res.status(200).send(graph)
        }
        else {
            console.log("Querying addresses for name " + req.params.address)
            const addresses = getAddressesByName(req.params.address)
            console.log(addresses)
            console.log("getting graphs")
            const graphs = await Promise.all(addresses.map(async addr => await new Address(addr).getSubgraph()))
            console.log("reducting graphs")
            const graph = graphs.reduce(mergeGraph)
            console.log("done!")
            res.status(200).send(graph)
        }
    } catch (e) {
        console.error(e)
        res.status(500).send("internal server error")

    }
})

export default route

function mergeGraph(graph1: IGraph, graph2: IGraph): IGraph {
    const id = (t: ITransfer) => t.from + t.to + t.token + t.block

    const includedAddresses = new Set(graph1.nodes.map(n => n.address))
    const includedTransfers = new Set(graph1.transfers.map(id))
    graph1.nodes.push(...graph2.nodes.filter(n => !includedAddresses.has(n.address)))
    graph1.transfers.push(...graph2.transfers.filter(t => !includedTransfers.has(id(t))))
    return graph1
}