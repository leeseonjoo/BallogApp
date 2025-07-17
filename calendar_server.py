#!/usr/bin/env python3
"""
Ballog Calendar Server
달력 기능을 위한 파이썬 서버
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import calendar
import datetime
from dateutil.relativedelta import relativedelta
import json

app = Flask(__name__)
CORS(app)

class CalendarService:
    def __init__(self):
        self.cal = calendar.Calendar()
    
    def get_month_calendar(self, year, month):
        """특정 월의 달력 데이터를 반환"""
        month_data = self.cal.monthdatescalendar(year, month)
        
        # 주차별로 데이터 구성
        weeks = []
        for week_num, week in enumerate(month_data, 1):
            week_data = []
            for date in week:
                is_current_month = date.month == month
                is_today = date == datetime.date.today()
                
                week_data.append({
                    'date': date.strftime('%Y-%m-%d'),
                    'day': date.day,
                    'is_current_month': is_current_month,
                    'is_today': is_today,
                    'weekday': date.weekday()  # 0=월요일, 6=일요일
                })
            weeks.append({
                'week_number': week_num,
                'days': week_data
            })
        
        return {
            'year': year,
            'month': month,
            'month_name': datetime.date(year, month, 1).strftime('%B'),
            'weeks': weeks,
            'total_weeks': len(weeks)
        }
    
    def get_week_calendar(self, year, month, day):
        """특정 주의 달력 데이터를 반환"""
        target_date = datetime.date(year, month, day)
        week_start = target_date - datetime.timedelta(days=target_date.weekday())
        
        week_data = []
        for i in range(7):
            date = week_start + datetime.timedelta(days=i)
            week_data.append({
                'date': date.strftime('%Y-%m-%d'),
                'day': date.day,
                'is_current_month': date.month == month,
                'is_today': date == datetime.date.today(),
                'weekday': date.weekday()
            })
        
        return {
            'year': year,
            'month': month,
            'week_start': week_start.strftime('%Y-%m-%d'),
            'week_end': (week_start + datetime.timedelta(days=6)).strftime('%Y-%m-%d'),
            'days': week_data
        }
    
    def get_holidays(self, year, month):
        """한국의 공휴일 정보를 반환"""
        holidays = {
            '2025': {
                '1': [1],  # 신정
                '2': [],   # 설날은 음력이라 별도 계산 필요
                '3': [1],  # 삼일절
                '5': [5],  # 어린이날
                '6': [6],  # 현충일
                '8': [15], # 광복절
                '10': [3, 9], # 개천절, 한글날
                '12': [25] # 크리스마스
            }
        }
        
        return holidays.get(str(year), {}).get(str(month), [])
    
    def calculate_week_of_month(self, year, month, day):
        """특정 날짜의 월 주차를 계산"""
        target_date = datetime.date(year, month, day)
        first_day = datetime.date(year, month, 1)
        
        # 첫 주의 시작일 계산 (월요일 기준)
        first_weekday = first_day.weekday()
        first_week_start = first_day - datetime.timedelta(days=first_weekday)
        
        # 주차 계산
        days_diff = (target_date - first_week_start).days
        week_number = (days_diff // 7) + 1
        
        return week_number

calendar_service = CalendarService()

@app.route('/api/calendar/month/<int:year>/<int:month>', methods=['GET'])
def get_month_calendar(year, month):
    """월 달력 데이터 반환"""
    try:
        data = calendar_service.get_month_calendar(year, month)
        holidays = calendar_service.get_holidays(year, month)
        data['holidays'] = holidays
        return jsonify(data)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/calendar/week/<int:year>/<int:month>/<int:day>', methods=['GET'])
def get_week_calendar(year, month, day):
    """주 달력 데이터 반환"""
    try:
        data = calendar_service.get_week_calendar(year, month, day)
        return jsonify(data)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/calendar/week-of-month/<int:year>/<int:month>/<int:day>', methods=['GET'])
def get_week_of_month(year, month, day):
    """특정 날짜의 월 주차 반환"""
    try:
        week_number = calendar_service.calculate_week_of_month(year, month, day)
        return jsonify({
            'year': year,
            'month': month,
            'day': day,
            'week_number': week_number
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/calendar/current', methods=['GET'])
def get_current_calendar():
    """현재 날짜의 달력 정보 반환"""
    try:
        today = datetime.date.today()
        month_data = calendar_service.get_month_calendar(today.year, today.month)
        week_number = calendar_service.calculate_week_of_month(today.year, today.month, today.day)
        
        return jsonify({
            'current_date': today.strftime('%Y-%m-%d'),
            'year': today.year,
            'month': today.month,
            'day': today.day,
            'week_number': week_number,
            'month_data': month_data
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/calendar/events', methods=['GET'])
def get_events():
    """이벤트 목록 반환 (샘플 데이터)"""
    try:
        events = [
            {
                'id': 1,
                'title': '팀 훈련',
                'date': '2025-07-15',
                'type': 'training',
                'description': '기술 훈련 및 체력 훈련'
            },
            {
                'id': 2,
                'title': '친선 경기',
                'date': '2025-07-20',
                'type': 'match',
                'description': 'OO팀과의 친선 경기'
            },
            {
                'id': 3,
                'title': '개인 훈련',
                'date': '2025-07-18',
                'type': 'personal',
                'description': '개인 기술 연습'
            }
        ]
        return jsonify(events)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/calendar/events', methods=['POST'])
def add_event():
    """새 이벤트 추가"""
    try:
        data = request.get_json()
        # 실제로는 데이터베이스에 저장
        event = {
            'id': len(data.get('events', [])) + 1,
            'title': data.get('title'),
            'date': data.get('date'),
            'type': data.get('type'),
            'description': data.get('description', '')
        }
        return jsonify(event), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    print("Ballog Calendar Server 시작...")
    print("서버 주소: http://localhost:5000")
    app.run(debug=True, host='0.0.0.0', port=5000)

