from flask import Flask, request, jsonify, Response
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

app = Flask(__name__)

# Retrieve environment variables
mysql_user = os.getenv('MYSQL_USER')
mysql_password = os.getenv('MYSQL_PASSWORD')
mysql_host = os.getenv('MYSQL_HOST')
mysql_db = os.getenv('MYSQL_DB')

# Configure SQLAlchemy with environment variables
app.config['SQLALCHEMY_DATABASE_URI'] = f'mysql+pymysql://{mysql_user}:{mysql_password}@{mysql_host}/{mysql_db}'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)
ma = Marshmallow(app)

class User(db.Model):
    __tablename__ = 'users'
    user_id = db.Column(db.Integer, primary_key=True)
    nickname = db.Column(db.String(100))
    email = db.Column(db.String(100))
    birth = db.Column(db.Date)
    uid = db.Column(db.String(100))
  
class Survey(db.Model):
    __tablename__ = 'survey'
    survey_id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.user_id'))
    question1 = db.Column(db.Integer)
    question2 = db.Column(db.Integer)
    question3 = db.Column(db.Integer)
    question4 = db.Column(db.Integer)
    question5 = db.Column(db.Integer)

@app.route('/recommend', methods=['POST'])
def recommend_user():
    data = request.get_json()
    query_answers = np.array([data['question1'], data['question2'], data['question3'], data['question4'], data['question5']])
    query_user_id = data['userId']
    surveys = Survey.query.filter(Survey.user_id != query_user_id).all()  
    max_similarity = -1
    most_similar_user_id = None
    
    for survey in surveys:
        survey_answers = np.array([survey.question1, survey.question2, survey.question3, survey.question4, survey.question5])
        similarity = cosine_similarity([query_answers], [survey_answers])[0][0]
        if similarity > max_similarity:
            max_similarity = similarity
            most_similar_user_id = survey.user_id
    
    if most_similar_user_id is not None:
        print(most_similar_user_id)
        return Response(str(most_similar_user_id), mimetype='text/plain')
    else:
        return jsonify({'error': 'No similar user found'}), 404

if __name__ == '__main__':
    app.run(debug=True)
