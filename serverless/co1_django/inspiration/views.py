import google
from django.http import HttpResponse
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.Certificate("ServiceAccountKey.json")
default_app = firebase_admin.initialize_app(cred)
db = firestore.client(default_app)
doc_ref = db.collection("sampleData").document("inspiration")


@api_view(["GET", "POST"])
def index(request):
    if request.method == "GET":
        try:
            doc = doc_ref.get()
            return Response(doc.to_dict())
        except google.cloud.exceptions.NotFound:
            return Response({"error": "Not Found"}, status=status.HTTP_400_BAD_REQUEST)

    elif request.method == "POST":
        data = request.data
        if not (data.get("quote") and data.get("author")):
            return Response({"error": "Your data should include quote and author"}, status=status.HTTP_400_BAD_REQUEST)

        quote, author = data["quote"], data["author"]

        doc_ref.set({
            "quote": quote,
            "author": author,
        })

        return Response(request.data,status=status.HTTP_201_CREATED)
