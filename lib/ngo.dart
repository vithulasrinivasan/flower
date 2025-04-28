import 'package:flutter/material.dart';

void main() {
  runApp(NGOConnectApp());
}

class NGOConnectApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NGO Connect',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: RoleSelectionScreen(),
    );
  }
}

// Model for Donation
class Donation {
  final String title;
  final String description;
  final List<String> chatMessages; // Chat messages between donor and NGO

  Donation({required this.title, required this.description, required this.chatMessages});
}

// Global in-memory list of donations
List<Donation> donationList = [];

class RoleSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('NGO Connect')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('I am a Donor'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DonorHomeScreen()),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('I am an NGO'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NGOHomeScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DonorHomeScreen extends StatefulWidget {
  @override
  _DonorHomeScreenState createState() => _DonorHomeScreenState();
}

class _DonorHomeScreenState extends State<DonorHomeScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  void postDonation() {
    if (titleController.text.isNotEmpty && descController.text.isNotEmpty) {
      setState(() {
        donationList.add(Donation(
          title: titleController.text,
          description: descController.text,
          chatMessages: [],
        ));
        titleController.clear();
        descController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Donation Posted Successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donor Dashboard'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Donation Title'),
            ),
            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: 'Donation Description'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: postDonation,
              child: Text('Post Donation'),
            ),
          ],
        ),
      ),
    );
  }
}

class NGOHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NGO Dashboard'),
      ),
      body: ListView.builder(
        itemCount: donationList.length,
        itemBuilder: (context, index) {
          final donation = donationList[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(donation.title),
              subtitle: Text(donation.description),
              trailing: Icon(Icons.chat),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(donation: donation),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final Donation donation;

  ChatScreen({required this.donation});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();

  void sendMessage() {
    if (messageController.text.isNotEmpty) {
      setState(() {
        widget.donation.chatMessages.add(messageController.text);
        messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat about "${widget.donation.title}"'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.donation.chatMessages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(widget.donation.chatMessages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(hintText: 'Enter message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
