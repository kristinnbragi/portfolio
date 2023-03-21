using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AudioGraph : MonoBehaviour
{
    public AdjacencyList<Node> _nodes {get; private set;}

    private void Awake()
    {
        var children = transform.GetComponentsInChildren<Node>();

        if (children.Length == 0) throw new ArgumentException("Trying to use " + this.ToString() + " without any Nodes component in children.");
        
        // Make sure connections are synced
        EnsureSync(ref children);

        // Construct an adjacency list with child objects
        // add first child as root,
        _nodes = new AdjacencyList<Node>(children[0]);
        
        // then, recursively add its connections as edges
        AddConnectionsAsEdges(children[0], null);

        _nodes.LogList();
        
        
    }

    void EnsureSync(ref Node[] nodes)
    {
        for (int i = 0; i < nodes.Length; i++)
        {
            for (int j = 0; j < nodes[i].connections.Count; j++)
            {
                if (!nodes[i].connections[j].connections.Contains(nodes[i]))
                    nodes[i].connections[j].connections.Add(nodes[i]);
            }
        }
    }

    void AddConnectionsAsEdges(Node node, Node prevNode)
    {
        foreach (var c in node.connections)
        {
            bool contains = _nodes.Contains(c);
            if (c != prevNode) _nodes.AddEdge(node, c);
            if (!contains) AddConnectionsAsEdges(c, node);
        }
    }

    public Node FindClosestNode(Vector3 origin)
    {
        Node closest = _nodes[0][0];
        float dist = Vector3.Magnitude(origin - _nodes[0][0].transform.position);

        for (int i = 1; i < _nodes.Length; i++)
        {
            float newDist = Vector3.Magnitude(origin - _nodes[i][0].transform.position);
            if (newDist < dist)
            {
                dist = newDist;
                closest = _nodes[i][0];
            }
        }
        Debug.Log(dist);
        return closest;
    }
}
