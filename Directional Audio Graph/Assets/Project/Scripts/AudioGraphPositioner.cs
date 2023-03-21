using System.ComponentModel;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AudioGraphPositioner : MonoBehaviour
{
    public bool debugMode = false;
    public AudioGraph graph;
    public Transform lureObject;
    public LayerMask layers;
    private Node homeNode;
    private Vector3 origin;
    private AudioSource src;

    private class Path {
        public Path (List<Node> nodes, float distance)
        {
            this.nodes = nodes;
            this.distance = distance;
        }
        public List<Node> nodes;
        public float distance;
        public Node playerNode = null;
    }

    void Start()
    {
        origin = transform.position;
        homeNode = graph.FindClosestNode(origin);
        src = GetComponent<AudioSource>();
    }

    void Update()
    {
        if (debugMode) Node.Highlight(graph.FindClosestNode(transform.position));

        float distanceToSource;

        if (Visible(origin))
        {
            transform.position = origin;
            distanceToSource = Vector3.Magnitude(lureObject.transform.position - origin);
        }
        else
        {
            Path path = null;
            Node visibleNode = FindFirstVisibleNode(homeNode, ref path, null);
            if (visibleNode != null)
                transform.position = visibleNode.transform.position;
            else
                Debug.Log("Could not find any visible node");

            float distanceToPath = Vector3.Magnitude(lureObject.transform.position - path.nodes[0].transform.position);
            distanceToSource = path.distance + distanceToPath;
            
            Vector3 toNode = path.nodes[0].transform.position;
            Vector3 fromNode = path.nodes.Count > 0 ? path.nodes[1].transform.position : toNode;
            float weight = path.playerNode ? distanceToPath / Vector3.Magnitude(toNode - path.playerNode.transform.position) : distanceToPath / Vector3.Magnitude(fromNode - toNode);
            PositionOnGraph(fromNode, toNode, weight);
        }

        src.volume = 1 / (Mathf.Pow(distanceToSource * 0.1f, 2)) + 0.1f;
    }

    void PositionOnGraph(Vector3 from, Vector3 towards, float weight) {
        weight = Mathf.Clamp01(weight);
        transform.position = Vector3.Lerp(from, towards, weight);
    }

    Node FindFirstVisibleNode(Node from, List<Node> exploredNodes)
    {
        if (Visible(from.transform.position))
            return from;
        if (exploredNodes == null)
            exploredNodes = new List<Node>();
        exploredNodes.Add(from);
        List<Node> edges = graph._nodes.GetEdgesOfKey(from);
        foreach (Node edge in edges)
        {
            if (!exploredNodes.Contains(edge))
            {
                Node n = FindFirstVisibleNode(edge, exploredNodes);
                if (n != null)
                    return n;
            }
        }
        return null;
    }

    // Overridden method to allow for returning a path
    Node FindFirstVisibleNode(Node from, ref Path path, List<Node> exploredNodes)
    {
        if (path == null)
            path = new Path(new List<Node>(), 0);
        if (exploredNodes == null)
            exploredNodes = new List<Node>();
        List<Node> edges = graph._nodes.GetEdgesOfKey(from);
        exploredNodes.Add(from);
        if (Visible(from.transform.position))
        {
            path.nodes.Add(from);
            foreach (var edge in edges)
                if (!exploredNodes.Contains(edge) && Visible(edge.transform.position))
                    path.playerNode = edge;
            return from;
        }
        foreach (Node edge in edges)
        {
            if (!exploredNodes.Contains(edge))
            {
                Node n = FindFirstVisibleNode(edge, ref path, exploredNodes);
                if (n != null) {
                    path.distance += Vector3.Magnitude(from.transform.position - path.nodes[path.nodes.Count - 1].transform.position);
                    path.nodes.Add(from);
                    return n;
                }
            }
        }
        return null;
    }

    bool Visible(Vector3 position) {
        // Linecast from origin to lureObject
        if (Physics.Linecast(position, lureObject.position, out RaycastHit hit, layers))
        {
            return false;
        }
        else
        {
            return true;
        }
    }
}
